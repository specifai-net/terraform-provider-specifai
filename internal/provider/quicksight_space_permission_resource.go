package provider

import (
	"context"
	"errors"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var (
	_ resource.Resource              = &quicksightSpacePermissionResource{}
	_ resource.ResourceWithConfigure = &quicksightSpacePermissionResource{}
)

func NewQuicksightSpacePermissionResource() resource.Resource {
	return &quicksightSpacePermissionResource{}
}

type quicksightSpacePermissionResource struct {
	providerData *specifaiProviderData
}

type quicksightSpacePermissionResourceModel struct {
	SpaceId      types.String `tfsdk:"space_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Principal    types.String `tfsdk:"principal"`
	Actions      types.Set    `tfsdk:"actions"`
}

func (r *quicksightSpacePermissionResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_space_permission"
}

func (r *quicksightSpacePermissionResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"space_id": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"aws_account_id": schema.StringAttribute{
				Optional: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"principal": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"actions": schema.SetAttribute{
				ElementType: types.StringType,
				Required:    true,
			},
		},
	}
}

func (r *quicksightSpacePermissionResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	if req.ProviderData == nil {
		return
	}

	providerData, ok := req.ProviderData.(specifaiProviderData)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Resource Configure Type",
			fmt.Sprintf("Expected specifaiProviderData, got: %T", req.ProviderData),
		)
		return
	}

	r.providerData = &providerData
}

func (r *quicksightSpacePermissionResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightSpacePermissionResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Verify space exists
	_, spaceErr := r.providerData.Quicksight.DescribeSpace(ctx, &quicksight.DescribeSpaceInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(config.SpaceId.ValueString()),
	})
	if spaceErr != nil {
		resp.Diagnostics.AddError("Space not found", fmt.Sprintf("Cannot create permissions for non-existent space %s: %s", config.SpaceId.ValueString(), spaceErr.Error()))
		return
	}

	var actions []string
	diags = config.Actions.ElementsAs(ctx, &actions, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateSpacePermissions (Create): %s", config.SpaceId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateSpacePermissions(ctx, &quicksight.UpdateSpacePermissionsInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(config.SpaceId.ValueString()),
		GrantPermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(config.Principal.ValueString()),
				Actions:   actions,
			},
		},
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to create space permission", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightSpacePermissionResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightSpacePermissionResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	out, err := r.providerData.Quicksight.DescribeSpacePermissions(ctx, &quicksight.DescribeSpacePermissionsInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(state.SpaceId.ValueString()),
	})
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Unable to read space permissions", err.Error())
		return
	}

	var foundPermission *qstypes.ResourcePermission
	for _, perm := range out.Permissions {
		if *perm.Principal == state.Principal.ValueString() {
			foundPermission = &perm
			break
		}
	}

	if foundPermission == nil {
		resp.State.RemoveResource(ctx)
		return
	}

	actionsList, diags := types.SetValueFrom(ctx, types.StringType, foundPermission.Actions)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
	state.Actions = actionsList

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightSpacePermissionResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightSpacePermissionResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	var actions []string
	diags = config.Actions.ElementsAs(ctx, &actions, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateSpacePermissions (Update): %s", config.SpaceId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateSpacePermissions(ctx, &quicksight.UpdateSpacePermissionsInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(config.SpaceId.ValueString()),
		GrantPermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(config.Principal.ValueString()),
				Actions:   actions,
			},
		},
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to update space permission", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightSpacePermissionResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightSpacePermissionResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	var actions []string
	diags = state.Actions.ElementsAs(ctx, &actions, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateSpacePermissions (Delete): %s", state.SpaceId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateSpacePermissions(ctx, &quicksight.UpdateSpacePermissionsInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(state.SpaceId.ValueString()),
		RevokePermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(state.Principal.ValueString()),
				Actions:   actions,
			},
		},
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to delete space permission", err.Error())
		return
	}
}
