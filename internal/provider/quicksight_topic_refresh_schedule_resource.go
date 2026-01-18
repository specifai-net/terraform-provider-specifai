package provider

import (
	"context"
	"errors"
	"fmt"
	"time"

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
	_ resource.Resource              = &quicksightTopicRefreshScheduleResource{}
	_ resource.ResourceWithConfigure = &quicksightTopicRefreshScheduleResource{}
)

func NewQuicksightTopicRefreshScheduleResource() resource.Resource {
	return &quicksightTopicRefreshScheduleResource{}
}

type quicksightTopicRefreshScheduleResource struct {
	providerData *specifaiProviderData
}

type quicksightTopicRefreshScheduleResourceModel struct {
	TopicId              types.String `tfsdk:"topic_id"`
	DatasetId            types.String `tfsdk:"dataset_id"`
	DatasetName          types.String `tfsdk:"dataset_name"`
	AwsAccountId         types.String `tfsdk:"aws_account_id"`
	BasedOnSpiceSchedule types.Bool   `tfsdk:"based_on_spice_schedule"`
	IsEnabled            types.Bool   `tfsdk:"is_enabled"`
	StartingAt           types.String `tfsdk:"starting_at"`
	Timezone             types.String `tfsdk:"timezone"`
	RepeatAt             types.String `tfsdk:"repeat_at"`
	TopicScheduleType    types.String `tfsdk:"topic_schedule_type"`
}

func (r *quicksightTopicRefreshScheduleResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_topic_refresh_schedule"
}

func (r *quicksightTopicRefreshScheduleResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"topic_id": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"dataset_id": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"dataset_name": schema.StringAttribute{
				Optional: true,
			},
			"aws_account_id": schema.StringAttribute{
				Optional: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"based_on_spice_schedule": schema.BoolAttribute{
				Required: true,
			},
			"is_enabled": schema.BoolAttribute{
				Required: true,
			},
			"starting_at": schema.StringAttribute{
				Optional: true,
			},
			"timezone": schema.StringAttribute{
				Optional: true,
			},
			"repeat_at": schema.StringAttribute{
				Optional: true,
			},
			"topic_schedule_type": schema.StringAttribute{
				Optional: true,
			},
		},
	}
}

func (r *quicksightTopicRefreshScheduleResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightTopicRefreshScheduleResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightTopicRefreshScheduleResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Verify the topic exists before creating the refresh schedule
	describeTopicInput := &quicksight.DescribeTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
	}

	_, topicErr := r.providerData.Quicksight.DescribeTopic(ctx, describeTopicInput)
	if topicErr != nil {
		resp.Diagnostics.AddError("Topic not found", fmt.Sprintf("Cannot create refresh schedule for non-existent topic %s: %s", config.TopicId.ValueString(), topicErr.Error()))
		return
	}

	refreshSchedule := &qstypes.TopicRefreshSchedule{
		BasedOnSpiceSchedule: config.BasedOnSpiceSchedule.ValueBool(),
		IsEnabled:            aws.Bool(config.IsEnabled.ValueBool()),
	}

	if !config.TopicScheduleType.IsNull() {
		refreshSchedule.TopicScheduleType = qstypes.TopicScheduleType(config.TopicScheduleType.ValueString())
	}

	if !config.StartingAt.IsNull() {
		// Parse the time string - assuming RFC3339 format
		if startTime, err := time.Parse(time.RFC3339, config.StartingAt.ValueString()); err == nil {
			refreshSchedule.StartingAt = &startTime
		} else {
			resp.Diagnostics.AddError("Invalid starting_at format", "Expected RFC3339 format: "+err.Error())
			return
		}
	}
	if !config.Timezone.IsNull() {
		refreshSchedule.Timezone = aws.String(config.Timezone.ValueString())
	}
	if !config.RepeatAt.IsNull() {
		refreshSchedule.RepeatAt = aws.String(config.RepeatAt.ValueString())
	}

	createInput := &quicksight.CreateTopicRefreshScheduleInput{
		AwsAccountId:    awsAccountId,
		TopicId:         aws.String(config.TopicId.ValueString()),
		DatasetArn:      aws.String(fmt.Sprintf("arn:aws:quicksight:%s:%s:dataset/%s", r.providerData.Region, *awsAccountId, config.DatasetId.ValueString())),
		RefreshSchedule: refreshSchedule,
	}

	if !config.DatasetName.IsNull() {
		createInput.DatasetName = aws.String(config.DatasetName.ValueString())
	}

	tflog.Trace(ctx, fmt.Sprintf("CreateTopicRefreshSchedule: %v", config))
	_, err := r.providerData.Quicksight.CreateTopicRefreshSchedule(ctx, createInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create topic refresh schedule", err.Error())
		return
	}

	// Verify the refresh schedule was created by reading it back
	describeInput := &quicksight.DescribeTopicRefreshScheduleInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
		DatasetId:    aws.String(config.DatasetId.ValueString()),
	}

	_, err = r.providerData.Quicksight.DescribeTopicRefreshSchedule(ctx, describeInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to verify topic refresh schedule creation", "Refresh schedule was not created successfully: "+err.Error())
		return
	}

	// Always set the aws_account_id that was actually used
	if config.AwsAccountId.ValueString() != "" {
		config.AwsAccountId = types.StringValue(*awsAccountId)
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicRefreshScheduleResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightTopicRefreshScheduleResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	describeInput := &quicksight.DescribeTopicRefreshScheduleInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(state.TopicId.ValueString()),
		DatasetId:    aws.String(state.DatasetId.ValueString()),
	}

	tflog.Trace(ctx, fmt.Sprintf("DescribeTopicRefreshSchedule: %s", state.TopicId.ValueString()))
	output, err := r.providerData.Quicksight.DescribeTopicRefreshSchedule(ctx, describeInput)
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			// Resource doesn't exist, remove from state
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Failed to read topic refresh schedule", err.Error())
		return
	}

	// Update state with actual values from AWS
	if output.RefreshSchedule != nil {
		state.BasedOnSpiceSchedule = types.BoolValue(output.RefreshSchedule.BasedOnSpiceSchedule)
		state.IsEnabled = types.BoolValue(*output.RefreshSchedule.IsEnabled)
		// Only update optional fields if they were set in config
		if !state.StartingAt.IsNull() && output.RefreshSchedule.StartingAt != nil {
			state.StartingAt = types.StringValue(output.RefreshSchedule.StartingAt.Format(time.RFC3339))
		}
		if !state.Timezone.IsNull() && output.RefreshSchedule.Timezone != nil {
			state.Timezone = types.StringValue(*output.RefreshSchedule.Timezone)
		}
		if !state.RepeatAt.IsNull() && output.RefreshSchedule.RepeatAt != nil {
			state.RepeatAt = types.StringValue(*output.RefreshSchedule.RepeatAt)
		}
		if !state.TopicScheduleType.IsNull() {
			state.TopicScheduleType = types.StringValue(string(output.RefreshSchedule.TopicScheduleType))
		}
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicRefreshScheduleResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightTopicRefreshScheduleResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	refreshSchedule := &qstypes.TopicRefreshSchedule{
		BasedOnSpiceSchedule: config.BasedOnSpiceSchedule.ValueBool(),
		IsEnabled:            aws.Bool(config.IsEnabled.ValueBool()),
	}

	if !config.TopicScheduleType.IsNull() {
		refreshSchedule.TopicScheduleType = qstypes.TopicScheduleType(config.TopicScheduleType.ValueString())
	}

	if !config.StartingAt.IsNull() {
		if startTime, err := time.Parse(time.RFC3339, config.StartingAt.ValueString()); err == nil {
			refreshSchedule.StartingAt = &startTime
		} else {
			resp.Diagnostics.AddError("Invalid starting_at format", "Expected RFC3339 format: "+err.Error())
			return
		}
	}
	if !config.Timezone.IsNull() {
		refreshSchedule.Timezone = aws.String(config.Timezone.ValueString())
	}
	if !config.RepeatAt.IsNull() {
		refreshSchedule.RepeatAt = aws.String(config.RepeatAt.ValueString())
	}

	updateInput := &quicksight.UpdateTopicRefreshScheduleInput{
		AwsAccountId:    awsAccountId,
		TopicId:         aws.String(config.TopicId.ValueString()),
		DatasetId:       aws.String(config.DatasetId.ValueString()),
		RefreshSchedule: refreshSchedule,
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateTopicRefreshSchedule: %v", config))
	_, err := r.providerData.Quicksight.UpdateTopicRefreshSchedule(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update topic refresh schedule", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTopicRefreshScheduleResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightTopicRefreshScheduleResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	deleteInput := &quicksight.DeleteTopicRefreshScheduleInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(state.TopicId.ValueString()),
		DatasetId:    aws.String(state.DatasetId.ValueString()),
	}

	tflog.Trace(ctx, fmt.Sprintf("DeleteTopicRefreshSchedule: %s", state.TopicId.ValueString()))
	_, err := r.providerData.Quicksight.DeleteTopicRefreshSchedule(ctx, deleteInput)
	if err != nil {
		// Ignore 404 errors as the resource may already be deleted
		var notFoundErr *qstypes.ResourceNotFoundException
		if !errors.As(err, &notFoundErr) {
			resp.Diagnostics.AddError("Failed to delete topic refresh schedule", err.Error())
		}
		return
	}
}
