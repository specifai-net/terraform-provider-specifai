package provider

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"slices"
	"time"

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
	_ resource.Resource              = &quicksightAgentResource{}
	_ resource.ResourceWithConfigure = &quicksightAgentResource{}
)

func NewQuicksightAgentResource() resource.Resource {
	return &quicksightAgentResource{}
}

type quicksightAgentResource struct {
	providerData *specifaiProviderData
}

type quicksightAgentResourceModel struct {
	AgentId            types.String `tfsdk:"agent_id"`
	AwsAccountId       types.String `tfsdk:"aws_account_id"`
	Name               types.String `tfsdk:"name"`
	Description        types.String `tfsdk:"description"`
	AgentLifecycle     types.String `tfsdk:"agent_lifecycle"`
	WelcomeMessage     types.String `tfsdk:"welcome_message"`
	IconId             types.String `tfsdk:"icon_id"`
	CustomInstructions types.String `tfsdk:"custom_instructions"`
	Identity           types.String `tfsdk:"identity"`
	OutputStyle        types.String `tfsdk:"output_style"`
	ResponseLength     types.String `tfsdk:"response_length"`
	Tone               types.String `tfsdk:"tone"`
	StarterPrompts     types.List   `tfsdk:"starter_prompts"`
	Spaces             types.List   `tfsdk:"spaces"`
	ActionConnectors   types.List   `tfsdk:"action_connectors"`
	Arn                types.String `tfsdk:"arn"`
}

func (r *quicksightAgentResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_chatagent"
}

func (r *quicksightAgentResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
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
			"agent_lifecycle": schema.StringAttribute{
				Optional: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"welcome_message": schema.StringAttribute{
				Optional: true,
			},
			"icon_id": schema.StringAttribute{
				Optional: true,
			},
			"custom_instructions": schema.StringAttribute{
				Optional: true,
			},
			"identity": schema.StringAttribute{
				Optional: true,
			},
			"output_style": schema.StringAttribute{
				Optional: true,
			},
			"response_length": schema.StringAttribute{
				Optional: true,
			},
			"tone": schema.StringAttribute{
				Optional: true,
			},
			"starter_prompts": schema.ListAttribute{
				Optional:    true,
				ElementType: types.StringType,
			},
			"spaces": schema.ListAttribute{
				Optional:    true,
				ElementType: types.StringType,
			},
			"action_connectors": schema.ListAttribute{
				Optional:    true,
				ElementType: types.StringType,
			},
			"arn": schema.StringAttribute{
				Computed: true,
			},
		},
	}
}

func (r *quicksightAgentResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightAgentResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightAgentResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	createInput := &quicksight.CreateAgentInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(config.AgentId.ValueString()),
		Name:         aws.String(config.Name.ValueString()),
	}

	if !config.Description.IsNull() {
		createInput.Description = aws.String(config.Description.ValueString())
	}
	if !config.AgentLifecycle.IsNull() {
		createInput.AgentLifecycle = qstypes.AgentLifecycle(config.AgentLifecycle.ValueString())
	}
	if !config.WelcomeMessage.IsNull() {
		createInput.WelcomeMessage = aws.String(config.WelcomeMessage.ValueString())
	}
	if !config.IconId.IsNull() {
		createInput.IconId = aws.String(config.IconId.ValueString())
	}

	// Custom prompt
	promptParams := buildCustomPromptParams(config)
	if promptParams != nil {
		createInput.CustomPromptInput = &qstypes.CustomPromptInputMemberNewPrompt{
			Value: *promptParams,
		}
	}

	// List fields
	if !config.StarterPrompts.IsNull() {
		var prompts []string
		diags = config.StarterPrompts.ElementsAs(ctx, &prompts, false)
		resp.Diagnostics.Append(diags...)
		if resp.Diagnostics.HasError() {
			return
		}
		createInput.StarterPrompts = prompts
	}
	if !config.Spaces.IsNull() {
		var spaces []string
		diags = config.Spaces.ElementsAs(ctx, &spaces, false)
		resp.Diagnostics.Append(diags...)
		if resp.Diagnostics.HasError() {
			return
		}
		createInput.Spaces = spaces
	}
	if !config.ActionConnectors.IsNull() {
		var connectors []string
		diags = config.ActionConnectors.ElementsAs(ctx, &connectors, false)
		resp.Diagnostics.Append(diags...)
		if resp.Diagnostics.HasError() {
			return
		}
		createInput.ActionConnectors = connectors
	}

	tflog.Trace(ctx, fmt.Sprintf("CreateAgent: %s", config.AgentId.ValueString()))
	out, err := r.providerData.Quicksight.CreateAgent(ctx, createInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create agent", err.Error())
		return
	}

	// Wait for agent to become ACTIVE
	if err := r.waitForAgentActive(ctx, awsAccountId, config.AgentId.ValueString()); err != nil {
		resp.Diagnostics.AddError("Agent failed to become active after creation", err.Error())
		return
	}

	config.Arn = types.StringValue(*out.Arn)
	config.AwsAccountId = types.StringValue(*awsAccountId)

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightAgentResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightAgentResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	out, err := r.providerData.Quicksight.DescribeAgent(ctx, &quicksight.DescribeAgentInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(state.AgentId.ValueString()),
	})
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Failed to read agent", err.Error())
		return
	}

	if out.Agent != nil {
		state.Name = types.StringValue(*out.Agent.Name)
		state.Arn = types.StringValue(*out.Agent.Arn)
		state.AgentLifecycle = types.StringValue(string(out.Agent.AgentLifecycle))
		if out.Agent.Description != nil {
			state.Description = types.StringValue(*out.Agent.Description)
		}
		if out.Agent.WelcomeMessage != nil {
			state.WelcomeMessage = types.StringValue(*out.Agent.WelcomeMessage)
		}
		if out.Agent.IconId != nil {
			state.IconId = types.StringValue(*out.Agent.IconId)
		}
		if out.Agent.CustomPromptInterface != nil {
			if out.Agent.CustomPromptInterface.CustomInstructions != nil {
				state.CustomInstructions = types.StringValue(*out.Agent.CustomPromptInterface.CustomInstructions)
			}
			if out.Agent.CustomPromptInterface.Identity != nil {
				state.Identity = types.StringValue(*out.Agent.CustomPromptInterface.Identity)
			}
			if out.Agent.CustomPromptInterface.OutputStyle != nil {
				state.OutputStyle = types.StringValue(*out.Agent.CustomPromptInterface.OutputStyle)
			}
			if out.Agent.CustomPromptInterface.ResponseLength != nil {
				state.ResponseLength = types.StringValue(*out.Agent.CustomPromptInterface.ResponseLength)
			}
			if out.Agent.CustomPromptInterface.Tone != nil {
				state.Tone = types.StringValue(*out.Agent.CustomPromptInterface.Tone)
			}
		}
		if len(out.Agent.StarterPrompts) > 0 {
			prompts, diags := types.ListValueFrom(ctx, types.StringType, out.Agent.StarterPrompts)
			resp.Diagnostics.Append(diags...)
			state.StarterPrompts = prompts
		}
		if len(out.Agent.Spaces) > 0 {
			spaces, diags := types.ListValueFrom(ctx, types.StringType, out.Agent.Spaces)
			resp.Diagnostics.Append(diags...)
			state.Spaces = spaces
		}
		if len(out.Agent.ActionConnectors) > 0 {
			connectors, diags := types.ListValueFrom(ctx, types.StringType, out.Agent.ActionConnectors)
			resp.Diagnostics.Append(diags...)
			state.ActionConnectors = connectors
		}
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightAgentResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightAgentResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var state quicksightAgentResourceModel
	diags = req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	updateInput := &quicksight.UpdateAgentInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(config.AgentId.ValueString()),
		Name:         aws.String(config.Name.ValueString()),
	}

	if !config.Description.IsNull() {
		updateInput.Description = aws.String(config.Description.ValueString())
	}
	if !config.WelcomeMessage.IsNull() {
		updateInput.WelcomeMessage = aws.String(config.WelcomeMessage.ValueString())
	}
	if !config.IconId.IsNull() {
		updateInput.IconId = aws.String(config.IconId.ValueString())
	}

	// Custom prompt
	promptParams := buildCustomPromptParams(config)
	if promptParams != nil {
		updateInput.CustomPromptInput = &qstypes.CustomPromptInputMemberNewPrompt{
			Value: *promptParams,
		}
	}

	if !config.StarterPrompts.IsNull() {
		var prompts []string
		diags = config.StarterPrompts.ElementsAs(ctx, &prompts, false)
		resp.Diagnostics.Append(diags...)
		if resp.Diagnostics.HasError() {
			return
		}
		updateInput.StarterPrompts = prompts
	}

	// Handle spaces diff
	var oldSpaces, newSpaces []string
	if !state.Spaces.IsNull() {
		state.Spaces.ElementsAs(ctx, &oldSpaces, false)
	}
	if !config.Spaces.IsNull() {
		config.Spaces.ElementsAs(ctx, &newSpaces, false)
	}
	updateInput.SpacesToAdd = slices.DeleteFunc(newSpaces, func(s string) bool { return slices.Contains(oldSpaces, s) })
	updateInput.SpacesToRemove = slices.DeleteFunc(oldSpaces, func(s string) bool { return slices.Contains(newSpaces, s) })

	// Handle action connectors diff
	var oldConnectors, newConnectors []string
	if !state.ActionConnectors.IsNull() {
		state.ActionConnectors.ElementsAs(ctx, &oldConnectors, false)
	}
	if !config.ActionConnectors.IsNull() {
		config.ActionConnectors.ElementsAs(ctx, &newConnectors, false)
	}
	updateInput.ActionConnectorsToAdd = slices.DeleteFunc(newConnectors, func(s string) bool { return slices.Contains(oldConnectors, s) })
	updateInput.ActionConnectorsToRemove = slices.DeleteFunc(oldConnectors, func(s string) bool { return slices.Contains(newConnectors, s) })

	tflog.Trace(ctx, fmt.Sprintf("UpdateAgent: %s", config.AgentId.ValueString()))

	// Wait for agent to be ACTIVE before updating
	if err := r.waitForAgentActive(ctx, awsAccountId, config.AgentId.ValueString()); err != nil {
		resp.Diagnostics.AddError("Agent not ready for update", err.Error())
		return
	}

	_, err := r.providerData.Quicksight.UpdateAgent(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update agent", err.Error())
		return
	}

	// Wait for agent to become ACTIVE after update
	if waitErr := r.waitForAgentActive(ctx, awsAccountId, config.AgentId.ValueString()); waitErr != nil {
		resp.Diagnostics.AddError("Agent failed to become active after update", waitErr.Error())
		return
	}

	config.Arn = state.Arn
	config.AwsAccountId = state.AwsAccountId

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightAgentResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightAgentResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	tflog.Trace(ctx, fmt.Sprintf("DeleteAgent: %s", state.AgentId.ValueString()))
	_, err := r.providerData.Quicksight.DeleteAgent(ctx, &quicksight.DeleteAgentInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(state.AgentId.ValueString()),
	})
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if !errors.As(err, &notFoundErr) {
			resp.Diagnostics.AddError("Failed to delete agent", err.Error())
		}
	}
}

func buildCustomPromptParams(config quicksightAgentResourceModel) *qstypes.CustomPromptInputParameters {
	hasPrompt := !config.CustomInstructions.IsNull() || !config.Identity.IsNull() ||
		!config.OutputStyle.IsNull() || !config.ResponseLength.IsNull() || !config.Tone.IsNull()
	if !hasPrompt {
		return nil
	}

	params := &qstypes.CustomPromptInputParameters{}
	if !config.CustomInstructions.IsNull() {
		params.CustomInstructions = aws.String(config.CustomInstructions.ValueString())
	}
	if !config.Identity.IsNull() {
		params.Identity = aws.String(config.Identity.ValueString())
	}
	if !config.OutputStyle.IsNull() {
		params.OutputStyle = aws.String(config.OutputStyle.ValueString())
	}
	if !config.ResponseLength.IsNull() {
		params.ResponseLength = aws.String(config.ResponseLength.ValueString())
	}
	if !config.Tone.IsNull() {
		params.Tone = aws.String(config.Tone.ValueString())
	}
	return params
}

func (r *quicksightAgentResource) waitForAgentActive(ctx context.Context, awsAccountId *string, agentId string) error {
	err := WaitForCondition(ctx, 30*time.Second, func() (bool, error) {
		out, err := r.providerData.Quicksight.DescribeAgent(ctx, &quicksight.DescribeAgentInput{
			AwsAccountId: awsAccountId,
			AgentId:      aws.String(agentId),
		})
		if err != nil {
			tflog.Warn(ctx, fmt.Sprintf("Failed to check agent status: %s, proceeding anyway", err.Error()))
			return true, nil
		}
		if out.Agent == nil {
			return true, nil
		}
		if out.Agent.AgentStatus == qstypes.AgentStatusFailed {
			return false, fmt.Errorf("agent %s is in FAILED status", agentId)
		}
		tflog.Debug(ctx, fmt.Sprintf("Waiting for agent %s to become ACTIVE (current: %s)", agentId, out.Agent.AgentStatus))
		return out.Agent.AgentStatus == qstypes.AgentStatusActive, nil
	})
	if _, isTimeout := err.(*TimeoutError); isTimeout {
		tflog.Warn(ctx, fmt.Sprintf("Timed out waiting for agent %s to become ACTIVE, proceeding", agentId))
		return nil
	}
	return err
}
