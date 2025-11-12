package provider

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"slices"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework-validators/setvalidator"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-framework/types/basetypes"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// Ensure the implementation satisfies the expected interfaces.
var (
	_ resource.Resource              = &quicksightDashboardPermissionResource{}
	_ resource.ResourceWithConfigure = &quicksightDashboardPermissionResource{}
)

type quicksightDashboardPermissionResourceModel struct {
	DashboardId  types.String   `tfsdk:"dashboard_id"`
	AwsAccountId types.String   `tfsdk:"aws_account_id"`
	Principal    types.String   `tfsdk:"principal"`
	Actions      []types.String `tfsdk:"actions"`
}

// NewQuicksightDashboardResource is a helper function to simplify the provider implementation.
func NewQuicksightDashboardPermissionResource() resource.Resource {
	return &quicksightDashboardPermissionResource{}
}

// quicksightDashboardPermissionResource is the resource implementation.
type quicksightDashboardPermissionResource struct {
	providerData *specifaiProviderData
}

// Metadata returns the resource type name.
func (r *quicksightDashboardPermissionResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_dashboard_permission"
}

// Schema defines the schema for the resource.
func (r *quicksightDashboardPermissionResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Description: `Defines permissions for a QuickSight dashboard and a given principal. Note that this resource can be somewhat
			tricky because QuickSight does not provide an id for a set of permissions and this provider will use the principal as
			an identifier. This means that if you create multiple dashboard permission resources for the same dashboard and principle
			they will conflict and the end result will be undefined.`,
		Attributes: map[string]schema.Attribute{
			"dashboard_id": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"aws_account_id": schema.StringAttribute{
				Optional: true,
				Computed: true,
				Validators: []validator.String{
					stringvalidator.RegexMatches(
						regexp.MustCompile(`^\d{12}$`),
						"must look like an AWS Account ID (exactly 12 digits)",
					),
				},
			},
			"principal": schema.StringAttribute{
				Required: true,
				Validators: []validator.String{
					stringvalidator.LengthBetween(1, 256),
				},
			},
			"actions": schema.SetAttribute{
				Required: true,
				Validators: []validator.Set{
					setvalidator.SizeBetween(1, 16),
					setvalidator.ValueStringsAre(stringvalidator.LengthAtLeast(1)),
				},
				ElementType: types.StringType,
			},
		},
	}
}

// Create creates the resource and sets the initial Terraform state.
func (r *quicksightDashboardPermissionResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardPermissionResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Update permissions
	var result quicksightDashboardPermissionResourceModel
	r.updateDashboardPermissions(ctx, resp.Diagnostics, &config, &result)
	if resp.Diagnostics.HasError() {
		return
	}

	// Set new state
	diags = resp.State.Set(ctx, &result)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Read refreshes the Terraform state with the latest data.
func (r *quicksightDashboardPermissionResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardPermissionResourceModel
	var state quicksightDashboardPermissionResourceModel
	diags := req.State.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Account id fallback
	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Read back the dashboard into the state
	state = config
	err := ReadDashboardPermissionsIntoResourceModel(ctx, r.providerData.Quicksight, aws.String(config.DashboardId.ValueString()), aws.String(config.Principal.ValueString()), awsAccountId, &state)
	if err != nil {
		if errors.As(err, &NOT_FOUND_ERROR) {
			resp.Diagnostics.AddWarning("Dashboard permissions not found, removing from state", err.Error())
			resp.State.RemoveResource(ctx)
		} else {
			resp.Diagnostics.AddError("Unable to read dashboard", err.Error())
		}
		return
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Update updates the resource and sets the updated Terraform state on success.
func (r *quicksightDashboardPermissionResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardPermissionResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Update permissions
	var result quicksightDashboardPermissionResourceModel
	r.updateDashboardPermissions(ctx, resp.Diagnostics, &config, &result)
	if resp.Diagnostics.HasError() {
		return
	}

	// Set new state
	diags = resp.State.Set(ctx, &result)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Delete deletes the resource and removes the Terraform state on success.
func (r *quicksightDashboardPermissionResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	// Retrieve values from the current state
	var config quicksightDashboardPermissionResourceModel
	diags := req.State.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Clear out all actions for this principal
	config.Actions = make([]basetypes.StringValue, 0)

	// Update permissions
	var result quicksightDashboardPermissionResourceModel
	r.updateDashboardPermissions(ctx, resp.Diagnostics, &config, &result)
	if resp.Diagnostics.HasError() {
		return
	}

	// Check result
	if len(result.Actions) > 0 {
		resp.Diagnostics.AddError(
			"Unexpected delete result",
			fmt.Sprintf("Principal %s still has %d permitted actions", *result.Principal.ValueStringPointer(), len(result.Actions)),
		)
	}
}

// Configure adds the provider configured client to the data source.
func (d *quicksightDashboardPermissionResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	if req.ProviderData == nil {
		return
	}

	specifaiProviderData, ok := req.ProviderData.(specifaiProviderData)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Resource Configure Type",
			fmt.Sprintf("Expected Specifai provider data: %T", req.ProviderData),
		)
		return
	}

	d.providerData = &specifaiProviderData
}

func (r *quicksightDashboardPermissionResource) updateDashboardPermissions(ctx context.Context, diag diag.Diagnostics, req *quicksightDashboardPermissionResourceModel, resp *quicksightDashboardPermissionResourceModel) {
	// Request parameters
	updateDashboardPermissionsInput := &quicksight.UpdateDashboardPermissionsInput{}
	updateDashboardPermissionsInput.DashboardId = aws.String(req.DashboardId.ValueString())
	updateDashboardPermissionsInput.AwsAccountId = aws.String(r.providerData.AccountId)
	if req.AwsAccountId.ValueString() != "" {
		updateDashboardPermissionsInput.AwsAccountId = aws.String(req.AwsAccountId.ValueString())
	}

	var principal = aws.String(req.Principal.ValueString())

	// Get the current permissions for the given principal
	var deployed quicksightDashboardPermissionResourceModel
	err := ReadDashboardPermissionsIntoResourceModel(ctx, r.providerData.Quicksight, updateDashboardPermissionsInput.DashboardId, principal, updateDashboardPermissionsInput.AwsAccountId, &deployed)
	if err != nil && !errors.As(err, &NOT_FOUND_ERROR) {
		diag.AddError("Unable to read dashboard", err.Error())
		return
	}

	// Diff the permissions
	for _, action := range req.Actions {
		if !slices.Contains(deployed.Actions, action) {
			if len(updateDashboardPermissionsInput.GrantPermissions) == 0 {
				updateDashboardPermissionsInput.GrantPermissions = make([]qstypes.ResourcePermission, 1)
				updateDashboardPermissionsInput.GrantPermissions[0] = qstypes.ResourcePermission{Principal: principal}
			}
			tflog.Debug(ctx, fmt.Sprintf("Grant action: %s", action))
			updateDashboardPermissionsInput.GrantPermissions[0].Actions = append(updateDashboardPermissionsInput.GrantPermissions[0].Actions, action.ValueString())
		}
	}
	for _, action := range deployed.Actions {
		if !slices.Contains(req.Actions, action) {
			if len(updateDashboardPermissionsInput.RevokePermissions) == 0 {
				updateDashboardPermissionsInput.RevokePermissions = make([]qstypes.ResourcePermission, 1)
				updateDashboardPermissionsInput.RevokePermissions[0] = qstypes.ResourcePermission{Principal: principal}
			}
			tflog.Debug(ctx, fmt.Sprintf("Revoke action: %s", action))
			updateDashboardPermissionsInput.RevokePermissions[0].Actions = append(updateDashboardPermissionsInput.RevokePermissions[0].Actions, action.ValueString())
		}
	}

	if len(updateDashboardPermissionsInput.GrantPermissions) > 0 || len(updateDashboardPermissionsInput.RevokePermissions) > 0 {
		// Do request
		tflog.Debug(ctx, fmt.Sprintf("UpdateDashboardPermissions: %v", updateDashboardPermissionsInput))
		out, err := r.providerData.Quicksight.UpdateDashboardPermissions(ctx, updateDashboardPermissionsInput)
		if err != nil {
			diag.AddError("Failed to update dashboard permissions", err.Error())
			return
		}
		tflog.Debug(ctx, fmt.Sprintf("UpdateDashboardPermissions returned %d", out.Status))

		// Build the resulting state from the response
		resp.DashboardId = types.StringValue(*out.DashboardId)
		resp.AwsAccountId = types.StringValue(*updateDashboardPermissionsInput.AwsAccountId)
		resp.Principal = req.Principal
		permission := FindPermissionForPrinciple(out.Permissions, resp.Principal.ValueStringPointer())
		if permission == nil {
			diag.AddError("Failed to update dashboard permissions", "Missing dashboard permissions for principal after update")
			return
		}
		resp.Actions = make([]basetypes.StringValue, len(permission.Actions))
		for j, action := range permission.Actions {
			resp.Actions[j] = types.StringValue(action)
		}
	} else {
		// No changes, return the existing desired state
		*resp = *req
		resp.AwsAccountId = types.StringValue(*updateDashboardPermissionsInput.AwsAccountId)
	}
}

func FindPermissionForPrinciple(permissions []qstypes.ResourcePermission, principal *string) *qstypes.ResourcePermission {
	for _, permission := range permissions {
		if *permission.Principal == *principal {
			return &permission
		}
	}
	return nil
}

func ReadDashboardPermissionsIntoResourceModel(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, principal *string, awsAccountId *string, resourceModel *quicksightDashboardPermissionResourceModel) error {
	// Get the dashboard, definition and permissions
	_, _, permissions, err := GetDashboardDefinitionAndPermissions(ctx, quicksightClient, dashboardId, awsAccountId, nil)
	if err != nil {
		return err
	}

	// Populate the given permission model
	resourceModel.DashboardId = types.StringValue(*dashboardId)
	permission := FindPermissionForPrinciple(permissions, principal)
	if permission != nil {
		resourceModel.Principal = types.StringValue(*permission.Principal)
		resourceModel.Actions = make([]basetypes.StringValue, len(permission.Actions))
		for j, action := range permission.Actions {
			resourceModel.Actions[j] = types.StringValue(action)
		}
		return nil
	}

	// Populate empty so we can use the input struct for comparison even if the function returns not found.
	resourceModel.Principal = types.StringValue(*principal)
	resourceModel.Actions = make([]basetypes.StringValue, 0)

	return &NotFoundError{}
}
