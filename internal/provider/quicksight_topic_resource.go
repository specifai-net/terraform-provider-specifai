package provider

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var (
	_ resource.Resource              = &quicksightTopicResource{}
	_ resource.ResourceWithConfigure = &quicksightTopicResource{}
)

func NewQuicksightTopicResource() resource.Resource {
	return &quicksightTopicResource{}
}

type quicksightTopicResource struct {
	providerData *specifaiProviderData
}

type quicksightTopicResourceModel struct {
	TopicId               types.String `tfsdk:"topic_id"`
	AwsAccountId          types.String `tfsdk:"aws_account_id"`
	Name                  types.String `tfsdk:"name"`
	Description           types.String `tfsdk:"description"`
	DataSets              types.String `tfsdk:"data_sets"`
	CustomInstructions    types.String `tfsdk:"custom_instructions"`
	UserExperienceVersion types.String `tfsdk:"user_experience_version"`
	Arn                   types.String `tfsdk:"arn"`
}

func (r *quicksightTopicResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_topic"
}

func (r *quicksightTopicResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
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
			},
			"description": schema.StringAttribute{
				Optional: true,
			},
			"data_sets": schema.StringAttribute{
				Required: true,
			},
			"custom_instructions": schema.StringAttribute{
				Optional: true,
			},
			"user_experience_version": schema.StringAttribute{
				Optional: true,
			},
			"arn": schema.StringAttribute{
				Computed: true,
			},
		},
	}
}

func (r *quicksightTopicResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightTopicResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightTopicResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	var dataSets []qstypes.DatasetMetadata
	if err := json.Unmarshal([]byte(config.DataSets.ValueString()), &dataSets); err != nil {
		resp.Diagnostics.AddError("Invalid datasets JSON", fmt.Sprintf("Failed to parse datasets JSON: %s", err.Error()))
		return
	}

	topicDetails := &qstypes.TopicDetails{
		Name:        aws.String(config.Name.ValueString()),
		Description: aws.String(config.Description.ValueString()),
		DataSets:    dataSets,
	}

	if !config.UserExperienceVersion.IsNull() {
		topicDetails.UserExperienceVersion = qstypes.TopicUserExperienceVersion(config.UserExperienceVersion.ValueString())
	}

	createInput := &quicksight.CreateTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
		Topic:        topicDetails,
	}

	if !config.CustomInstructions.IsNull() {
		createInput.CustomInstructions = &qstypes.CustomInstructions{
			CustomInstructionsString: aws.String(config.CustomInstructions.ValueString()),
		}
	}

	tflog.Trace(ctx, fmt.Sprintf("CreateTopic: %v", config))
	out, err := r.providerData.Quicksight.CreateTopic(ctx, createInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create topic", err.Error())
		return
	}

	// Set computed values
	config.Arn = types.StringValue(*out.Arn)
	config.AwsAccountId = types.StringValue(*awsAccountId)

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightTopicResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	describeInput := &quicksight.DescribeTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(state.TopicId.ValueString()),
	}

	out, err := r.providerData.Quicksight.DescribeTopic(ctx, describeInput)
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.Diagnostics.AddWarning("Topic not found, removing from state", err.Error())
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Unable to read topic", err.Error())
		return
	}

	if out.Topic != nil {
		state.Name = types.StringValue(*out.Topic.Name)
		if out.Topic.Description != nil {
			state.Description = types.StringValue(*out.Topic.Description)
		}
		state.Arn = types.StringValue(*out.Arn)

		dataSetsJSON, err := json.Marshal(out.Topic.DataSets)
		if err != nil {
			resp.Diagnostics.AddError("Failed to marshal datasets", err.Error())
			return
		}
		state.DataSets = types.StringValue(string(dataSetsJSON))
	}

	if out.CustomInstructions != nil {
		state.CustomInstructions = types.StringValue(*out.CustomInstructions.CustomInstructionsString)
	}

	if out.Topic != nil {
		state.UserExperienceVersion = types.StringValue(string(out.Topic.UserExperienceVersion))
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightTopicResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Get current state to preserve computed values
	var state quicksightTopicResourceModel
	diags = req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	var dataSets []qstypes.DatasetMetadata
	if err := json.Unmarshal([]byte(config.DataSets.ValueString()), &dataSets); err != nil {
		resp.Diagnostics.AddError("Invalid datasets JSON", fmt.Sprintf("Failed to parse datasets JSON: %s", err.Error()))
		return
	}

	updateInput := &quicksight.UpdateTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
		Topic: &qstypes.TopicDetails{
			Name:        aws.String(config.Name.ValueString()),
			Description: aws.String(config.Description.ValueString()),
			DataSets:    dataSets,
		},
	}

	if !config.UserExperienceVersion.IsNull() {
		updateInput.Topic.UserExperienceVersion = qstypes.TopicUserExperienceVersion(config.UserExperienceVersion.ValueString())
	}

	if !config.CustomInstructions.IsNull() {
		updateInput.CustomInstructions = &qstypes.CustomInstructions{
			CustomInstructionsString: aws.String(config.CustomInstructions.ValueString()),
		}
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateTopic: %v", config))
	_, err := r.providerData.Quicksight.UpdateTopic(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update topic", err.Error())
		return
	}

	// Preserve computed values from state
	config.Arn = state.Arn
	config.AwsAccountId = types.StringValue(*awsAccountId)

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightTopicResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	deleteInput := &quicksight.DeleteTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(state.TopicId.ValueString()),
	}

	tflog.Trace(ctx, fmt.Sprintf("DeleteTopic: %s", state.TopicId.ValueString()))
	_, err := r.providerData.Quicksight.DeleteTopic(ctx, deleteInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to delete topic", err.Error())
		return
	}
}