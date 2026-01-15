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
	_ resource.Resource              = &quicksightTopicPermissionResource{}
	_ resource.ResourceWithConfigure = &quicksightTopicPermissionResource{}
)

func NewQuicksightTopicPermissionResource() resource.Resource {
	return &quicksightTopicPermissionResource{}
}

type quicksightTopicPermissionResource struct {
	providerData *specifaiProviderData
}

type quicksightTopicPermissionResourceModel struct {
	TopicId      types.String `tfsdk:"topic_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Principal    types.String `tfsdk:"principal"`
	Actions      types.List   `tfsdk:"actions"`
}

func (r *quicksightTopicPermissionResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_topic_permission"
}

func (r *quicksightTopicPermissionResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"topic_id": schema.StringAttribute{
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
			"actions": schema.ListAttribute{
				ElementType: types.StringType,
				Required:    true,
			},
		},
	}
}

func (r *quicksightTopicPermissionResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightTopicPermissionResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightTopicPermissionResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Verify the topic exists before creating permissions
	describeTopicInput := &quicksight.DescribeTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
	}

	_, topicErr := r.providerData.Quicksight.DescribeTopic(ctx, describeTopicInput)
	if topicErr != nil {
		resp.Diagnostics.AddError("Topic not found", fmt.Sprintf("Cannot create permissions for non-existent topic %s: %s", config.TopicId.ValueString(), topicErr.Error()))
		return
	}

	var actions []string
	diags = config.Actions.ElementsAs(ctx, &actions, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	updateInput := &quicksight.UpdateTopicPermissionsInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
		GrantPermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(config.Principal.ValueString()),
				Actions:   actions,
			},
		},
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateTopicPermissions (Create): %v", config))
	_, err := r.providerData.Quicksight.UpdateTopicPermissions(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create topic permission", err.Error())
		return
	}

	// Always set the aws_account_id that was actually used
	if config.AwsAccountId.ValueString() != "" {
		config.AwsAccountId = types.StringValue(*awsAccountId)
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicPermissionResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightTopicPermissionResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	describeInput := &quicksight.DescribeTopicPermissionsInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(state.TopicId.ValueString()),
	}

	out, err := r.providerData.Quicksight.DescribeTopicPermissions(ctx, describeInput)
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.Diagnostics.AddWarning("Topic permission not found, removing from state", err.Error())
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Unable to read topic permissions", err.Error())
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
		resp.Diagnostics.AddWarning("Topic permission not found for principal, removing from state", "")
		resp.State.RemoveResource(ctx)
		return
	}

	actionsList, diags := types.ListValueFrom(ctx, types.StringType, foundPermission.Actions)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
	state.Actions = actionsList

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicPermissionResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightTopicPermissionResourceModel
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

	updateInput := &quicksight.UpdateTopicPermissionsInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
		GrantPermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(config.Principal.ValueString()),
				Actions:   actions,
			},
		},
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateTopicPermissions (Update): %v", config))
	_, err := r.providerData.Quicksight.UpdateTopicPermissions(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update topic permission", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicPermissionResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightTopicPermissionResourceModel
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

	updateInput := &quicksight.UpdateTopicPermissionsInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(state.TopicId.ValueString()),
		RevokePermissions: []qstypes.ResourcePermission{
			{
				Principal: aws.String(state.Principal.ValueString()),
				Actions:   actions,
			},
		},
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateTopicPermissions (Delete): %s", state.TopicId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateTopicPermissions(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to delete topic permission", err.Error())
		return
	}
}
