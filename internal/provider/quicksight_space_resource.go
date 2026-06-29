package provider

import (
	"context"
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
	_ resource.Resource              = &quicksightSpaceResource{}
	_ resource.ResourceWithConfigure = &quicksightSpaceResource{}
)

func NewQuicksightSpaceResource() resource.Resource {
	return &quicksightSpaceResource{}
}

type quicksightSpaceResource struct {
	providerData *specifaiProviderData
}

type quicksightSpaceResourceModel struct {
	SpaceId      types.String `tfsdk:"space_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Name         types.String `tfsdk:"name"`
	Description  types.String `tfsdk:"description"`
	Arn          types.String `tfsdk:"arn"`
}

func (r *quicksightSpaceResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_space"
}

func (r *quicksightSpaceResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
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
			"arn": schema.StringAttribute{
				Computed: true,
			},
		},
	}
}

func (r *quicksightSpaceResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightSpaceResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightSpaceResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	createInput := &quicksight.CreateSpaceInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(config.SpaceId.ValueString()),
		Name:         aws.String(config.Name.ValueString()),
	}

	if !config.Description.IsNull() {
		createInput.Description = aws.String(config.Description.ValueString())
	}

	tflog.Trace(ctx, fmt.Sprintf("CreateSpace: %s", config.SpaceId.ValueString()))
	out, err := r.providerData.Quicksight.CreateSpace(ctx, createInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create space", err.Error())
		return
	}

	config.AwsAccountId = types.StringValue(*awsAccountId)
	if out.SpaceArn != nil {
		config.Arn = types.StringValue(*out.SpaceArn)
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightSpaceResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightSpaceResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	out, err := r.providerData.Quicksight.DescribeSpace(ctx, &quicksight.DescribeSpaceInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(state.SpaceId.ValueString()),
	})
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Failed to read space", err.Error())
		return
	}

	if out.SpaceArn != nil {
		state.Arn = types.StringValue(*out.SpaceArn)
	}
	if out.Space != nil {
		if out.Space.Name != nil {
			state.Name = types.StringValue(*out.Space.Name)
		}
		if out.Space.Description != nil {
			state.Description = types.StringValue(*out.Space.Description)
		}
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightSpaceResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightSpaceResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var state quicksightSpaceResourceModel
	diags = req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	updateInput := &quicksight.UpdateSpaceInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(config.SpaceId.ValueString()),
		Name:         aws.String(config.Name.ValueString()),
	}

	if !config.Description.IsNull() {
		updateInput.Description = aws.String(config.Description.ValueString())
	}

	tflog.Trace(ctx, fmt.Sprintf("UpdateSpace: %s", config.SpaceId.ValueString()))
	_, err := r.providerData.Quicksight.UpdateSpace(ctx, updateInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update space", err.Error())
		return
	}

	config.Arn = state.Arn
	config.AwsAccountId = state.AwsAccountId

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightSpaceResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightSpaceResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(r.providerData.AccountId)
	if state.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(state.AwsAccountId.ValueString())
	}

	tflog.Trace(ctx, fmt.Sprintf("DeleteSpace: %s", state.SpaceId.ValueString()))
	_, err := r.providerData.Quicksight.DeleteSpace(ctx, &quicksight.DeleteSpaceInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(state.SpaceId.ValueString()),
	})
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if !errors.As(err, &notFoundErr) {
			resp.Diagnostics.AddError("Failed to delete space", err.Error())
		}
	}
}
