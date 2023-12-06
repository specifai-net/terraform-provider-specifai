package provider

import (
	"context"
	"fmt"
	"regexp"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/cenkalti/backoff/v4"
	"github.com/hashicorp/terraform-plugin-framework-jsontypes/jsontypes"
	"github.com/hashicorp/terraform-plugin-framework-validators/listvalidator"
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
	"github.com/yudai/gojsondiff"
	"github.com/yudai/gojsondiff/formatter"
)

// Ensure the implementation satisfies the expected interfaces.
var (
	_ resource.Resource              = &quicksightDashboardResource{}
	_ resource.ResourceWithConfigure = &quicksightDashboardResource{}
)

type quicksightDashboardResourcePermissionModel struct {
	Principal types.String   `tfsdk:"principal"`
	Actions   []types.String `tfsdk:"actions"`
}

// orderItemCoffeeModel maps coffee order item data.
type quicksightDashboardResourceModel struct {
	DashboardId        types.String                                 `tfsdk:"dashboard_id"`
	AwsAccountId       types.String                                 `tfsdk:"aws_account_id"`
	Name               types.String                                 `tfsdk:"name"`
	Arn                types.String                                 `tfsdk:"arn"`
	Definition         jsontypes.Normalized                         `tfsdk:"definition"`
	Permissions        []quicksightDashboardResourcePermissionModel `tfsdk:"permissions"`
	CreatedTime        types.String                                 `tfsdk:"created_time"`
	LastUpdatedTime    types.String                                 `tfsdk:"last_updated_time"`
	LastPublishedTime  types.String                                 `tfsdk:"last_published_time"`
	Status             types.String                                 `tfsdk:"status"`
	VersionNumber      types.Int64                                  `tfsdk:"version_number"`
	VersionDescription types.String                                 `tfsdk:"version_description"`
}

// NewQuicksightDashboardResource is a helper function to simplify the provider implementation.
func NewQuicksightDashboardResource() resource.Resource {
	return &quicksightDashboardResource{}
}

// quicksightDashboardResource is the resource implementation.
type quicksightDashboardResource struct {
	providerData *specifaiProviderData
}

// Metadata returns the resource type name.
func (r *quicksightDashboardResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_dashboard"
}

// Schema defines the schema for the resource.
func (r *quicksightDashboardResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
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
			"name": schema.StringAttribute{
				Required: true,
				Validators: []validator.String{
					stringvalidator.LengthBetween(1, 2048),
				},
			},
			"arn": schema.StringAttribute{
				Computed: true,
			},
			"definition": schema.StringAttribute{
				Required:   true,
				CustomType: jsontypes.NormalizedType{},
			},
			"permissions": schema.ListNestedAttribute{
				Optional: true,
				Validators: []validator.List{
					listvalidator.SizeAtLeast(1),
				},
				NestedObject: schema.NestedAttributeObject{
					Attributes: map[string]schema.Attribute{
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
				},
			},
			"created_time": schema.StringAttribute{
				Computed: true,
			},
			"last_updated_time": schema.StringAttribute{
				Computed: true,
			},
			"last_published_time": schema.StringAttribute{
				Computed: true,
			},
			"status": schema.StringAttribute{
				Computed: true,
			},
			"version_number": schema.Int64Attribute{
				Computed: true,
			},
			"version_description": schema.StringAttribute{
				Required: true,
				Validators: []validator.String{
					stringvalidator.LengthBetween(1, 512),
				},
			},
		},
	}
}

// Create creates the resource and sets the initial Terraform state.
func (r *quicksightDashboardResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Request parameters
	createDashboardInput := &quicksight.CreateDashboardInput{}
	createDashboardInput.DashboardId = aws.String(config.DashboardId.ValueString())
	createDashboardInput.AwsAccountId = aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		createDashboardInput.AwsAccountId = aws.String(config.AwsAccountId.ValueString())
	}
	createDashboardInput.Name = aws.String(config.Name.ValueString())
	createDashboardInput.VersionDescription = aws.String((config.VersionDescription.ValueString()))
	if definition, err := JsonToNormalizedDefinition([]byte(config.Definition.ValueString())); err == nil {
		createDashboardInput.Definition = &definition
	} else {
		resp.Diagnostics.AddError("Invalid definition", err.Error())
	}
	createDashboardInput.Permissions = make([]qstypes.ResourcePermission, len(config.Permissions))
	for i, permission := range config.Permissions {
		createDashboardInput.Permissions[i] = qstypes.ResourcePermission{
			Principal: aws.String(permission.Principal.ValueString()),
			Actions:   make([]string, len(permission.Actions)),
		}
		for j, action := range permission.Actions {
			createDashboardInput.Permissions[i].Actions[j] = action.ValueString()
		}
	}

	// Do request
	tflog.Debug(ctx, fmt.Sprintf("CreateDashboard: %v", config))
	_, err := r.providerData.Quicksight.CreateDashboard(ctx, createDashboardInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create dashboard", err.Error())
		return
	}

	// Wait until dashboard has been created
	exp := backoff.NewExponentialBackOff()
	exp.InitialInterval = 1 * time.Second
	exp.Reset()
	var dashboard *qstypes.Dashboard
	for dashboard == nil || dashboard.Version.Status != qstypes.ResourceStatusCreationSuccessful {
		d, err := GetDashboard(ctx, r.providerData.Quicksight, createDashboardInput.DashboardId, createDashboardInput.AwsAccountId)
		if err != nil {
			resp.Diagnostics.AddWarning("Failed to create dashboard", err.Error())
		}
		dashboard = d
		if exp.GetElapsedTime() > 15*time.Minute {
			resp.Diagnostics.AddError("Failed to create dashboard", "Timed out waiting for dashboard ceration to complete")
		} else {
			time.Sleep(exp.NextBackOff())
		}
	}

	// Read back the dashboard into the state
	var state quicksightDashboardResourceModel
	err = ReadDashboardIntoResourceModel(ctx, r.providerData.Quicksight, createDashboardInput.DashboardId, createDashboardInput.AwsAccountId, &state)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create dashboard", err.Error())
	}

	// Our definition may not match what was return from quicksight which
	// generally means our definition is out of date and needs to be updated.
	// Here we compare the two and emit some diagnostic warnings when there are
	// differences. We can't really fail as this will impact onboarding new
	// customers.
	WarnForDefinitionDifferences([]byte(*config.Definition.ValueStringPointer()), []byte(*state.Definition.ValueStringPointer()), &resp.Diagnostics)

	// Set the state definition back to the original configured string because
	// this is what terraform requires.
	//
	// See:
	// https://developer.hashicorp.com/terraform/plugin/framework/resources/plan-modification#terraform-data-consistency-rules
	state.Definition = config.Definition

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Read refreshes the Terraform state with the latest data.
func (r *quicksightDashboardResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardResourceModel
	var state quicksightDashboardResourceModel
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
	err := ReadDashboardIntoResourceModel(ctx, r.providerData.Quicksight, aws.String(config.DashboardId.ValueString()), awsAccountId, &state)
	if err != nil {
		resp.Diagnostics.AddError("Unable to read dashboard", err.Error())
	}

	// The definition we read back from quicksight may be slightly different
	// from the JSON that is confifgured but could be semantically the same.
	// If this is the case we just return the configured JSON so we don't
	// trigger a useless update. We also warn of any definition changes
	// because our definition is out of date and needs to be updated.
	if configDefinitionJson, err := JsonToNormalizedDefinitionJson([]byte(*config.Definition.ValueStringPointer())); err == nil {
		if stateDefinitionJson, err := JsonToNormalizedDefinitionJson([]byte(*state.Definition.ValueStringPointer())); err == nil {
			if configDefinitionJson == stateDefinitionJson {
				WarnForDefinitionDifferences([]byte(configDefinitionJson), []byte(stateDefinitionJson), &resp.Diagnostics)
				state.Definition = config.Definition
			}
		} else {
			diags.AddWarning("Definition compare failed", err.Error())
		}
	} else {
		diags.AddWarning("Definition compare failed", err.Error())
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Update updates the resource and sets the updated Terraform state on success.
func (r *quicksightDashboardResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
}

// Delete deletes the resource and removes the Terraform state on success.
func (r *quicksightDashboardResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
}

// Configure adds the provider configured client to the data source.
func (d *quicksightDashboardResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func ReadDashboardIntoResourceModel(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, resourceModel *quicksightDashboardResourceModel) error {
	// Get the dashboard, definition and permissions
	dashboard, definition, permissions, err := GetDashboardDefinitionAndPermissions(ctx, quicksightClient, dashboardId, awsAccountId)
	if err != nil {
		return err
	}

	resourceModel.DashboardId = types.StringValue(*dashboardId)
	resourceModel.AwsAccountId = types.StringValue(*awsAccountId)
	resourceModel.Name = MaybeStringValue(dashboard.Name)
	resourceModel.Arn = types.StringValue(*dashboard.Arn)
	if json, err := DefinitionToNormalizedJson(definition); err == nil {
		resourceModel.Definition = jsontypes.NewNormalizedPointerValue(&json)
	} else {
		return err
	}
	resourceModel.Permissions = make([]quicksightDashboardResourcePermissionModel, len(permissions))
	for i, permission := range permissions {
		resourceModel.Permissions[i] = quicksightDashboardResourcePermissionModel{
			Principal: types.StringValue(*permission.Principal),
			Actions:   make([]basetypes.StringValue, len(permission.Actions)),
		}
		for j, action := range permission.Actions {
			resourceModel.Permissions[i].Actions[j] = types.StringValue(action)
		}
	}
	resourceModel.CreatedTime = types.StringValue(dashboard.CreatedTime.Format(time.RFC3339))
	resourceModel.LastUpdatedTime = types.StringValue(dashboard.LastUpdatedTime.Format(time.RFC3339))
	resourceModel.LastPublishedTime = types.StringValue(dashboard.LastPublishedTime.Format(time.RFC3339))
	resourceModel.Status = types.StringValue(string(dashboard.Version.Status))
	resourceModel.VersionNumber = types.Int64Value(*dashboard.Version.VersionNumber)
	resourceModel.VersionDescription = MaybeStringValue(dashboard.Version.Description)

	return nil
}

func WarnForDefinitionDifferences(left []byte, right []byte, diags *diag.Diagnostics) {
	differ := gojsondiff.New()
	if diff, err := differ.Compare(left, right); err == nil {
		if diff.Modified() {
			var orig interface{}
			DecodeJsonIntoStruct(left, &orig)
			formatter := formatter.NewAsciiFormatter(orig, formatter.AsciiFormatterConfig{
				ShowArrayIndex: false,
				Coloring:       false,
			})
			diffString, _ := formatter.Format(diff)
			diags.AddWarning("Definition outdated", fmt.Sprintf("The deployed definition differs from the configured definition:\n%s", diffString))
		}
	} else {
		diags.AddWarning("Definition diff failed", err.Error())
	}
}
