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
	_ resource.Resource              = &quicksightAgentPermissionResource{}
	_ resource.ResourceWithConfigure = &quicksightAgentPermissionResource{}
)

func NewQuicksightAgentPermissionResource() resource.Resource {
	return &quicksightAgentPermissionResource{}
}

type quicksightAgentPermissionResource struct {
	providerData *specifaiProviderData
}

type quicksightAgentPermissionResourceModel struct {
	AgentId      types.String `tfsdk:"agent_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Principal    types.String `tfsdk:"principal"`
	Actions      types.Set    `tfsdk:"actions"`
}

func (r *quicksightAgentPermissionResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_chatagent_permission"
}

func (r *quicksightAgentPermissionResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"agent_id": schema.StringAttribute{
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

func (r *quicksightAgentPermissionResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightAgentPermissionResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightAgentPermissionResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Verify the agent exists
	_, agentErr := r.providerData.Quicksight.DescribeAgent(ctx, &quicksight.DescribeAgentInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(config.AgentId.ValueString()),
	})
	if agentErr != nil {
		resp.Diagnostics.AddError("Agent not found", fmt.Sprintf("Cannot create permissions for non-existent agent %s: %s", config.AgentId.ValueString(), agentErr.Error()))
		return
	}

	var actions []string
	diags = config.Actions.ElementsAs(ctx, &actions, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateAgentPermissions (Create): %s", config.AgentId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateAgentPermissions(ctx, &quicksight.UpdateAgentPermissionsInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(config.AgentId.ValueString()),
		GrantPermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(config.Principal.ValueString()),
				Actions:   actions,
			},
		},
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to create agent permission", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightAgentPermissionResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightAgentPermissionResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	out, err := r.providerData.Quicksight.DescribeAgentPermissions(ctx, &quicksight.DescribeAgentPermissionsInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(state.AgentId.ValueString()),
	})
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Unable to read agent permissions", err.Error())
		return
	}

	// Find the specific permission for this principal
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

func (r *quicksightAgentPermissionResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightAgentPermissionResourceModel
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

	tflog.Trace(ctx, fmt.Sprintf("UpdateAgentPermissions (Update): %s", config.AgentId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateAgentPermissions(ctx, &quicksight.UpdateAgentPermissionsInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(config.AgentId.ValueString()),
		GrantPermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(config.Principal.ValueString()),
				Actions:   actions,
			},
		},
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to update agent permission", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightAgentPermissionResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightAgentPermissionResourceModel
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

	tflog.Trace(ctx, fmt.Sprintf("UpdateAgentPermissions (Delete): %s", state.AgentId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateAgentPermissions(ctx, &quicksight.UpdateAgentPermissionsInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(state.AgentId.ValueString()),
		RevokePermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(state.Principal.ValueString()),
				Actions:   actions,
			},
		},
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to delete agent permission", err.Error())
		return
	}
}
