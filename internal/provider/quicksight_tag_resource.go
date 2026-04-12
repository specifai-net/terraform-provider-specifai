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
	_ resource.Resource              = &quicksightTagResource{}
	_ resource.ResourceWithConfigure = &quicksightTagResource{}
)

func NewQuicksightTagResource() resource.Resource {
	return &quicksightTagResource{}
}

type quicksightTagResource struct {
	providerData *specifaiProviderData
}

type quicksightTagResourceModel struct {
	ResourceArn types.String `tfsdk:"resource_arn"`
	Tags        types.Map    `tfsdk:"tags"`
}

func (r *quicksightTagResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_tag"
}

func (r *quicksightTagResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"resource_arn": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"tags": schema.MapAttribute{
				Required:    true,
				ElementType: types.StringType,
			},
		},
	}
}

func (r *quicksightTagResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
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

func (r *quicksightTagResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	var config quicksightTagResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var tagsMap map[string]string
	diags = config.Tags.ElementsAs(ctx, &tagsMap, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	tags := make([]qstypes.Tag, 0, len(tagsMap))
	for k, v := range tagsMap {
		tags = append(tags, qstypes.Tag{
			Key:   aws.String(k),
			Value: aws.String(v),
		})
	}

	tflog.Trace(ctx, fmt.Sprintf("TagResource: %s", config.ResourceArn.ValueString()))
	_, err := r.providerData.Quicksight.TagResource(ctx, &quicksight.TagResourceInput{
		ResourceArn: aws.String(config.ResourceArn.ValueString()),
		Tags:        tags,
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to tag resource", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTagResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	var state quicksightTagResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("ListTagsForResource: %s", state.ResourceArn.ValueString()))
	output, err := r.providerData.Quicksight.ListTagsForResource(ctx, &quicksight.ListTagsForResourceInput{
		ResourceArn: aws.String(state.ResourceArn.ValueString()),
	})
	if err != nil {
		var notFound *qstypes.ResourceNotFoundException
		if errors.As(err, &notFound) {
			tflog.Warn(ctx, fmt.Sprintf("Resource %s not found, removing from state", state.ResourceArn.ValueString()))
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Failed to read tags", err.Error())
		return
	}

	// Only track tags that we manage (present in state)
	var managedKeys map[string]string
	diags = state.Tags.ElementsAs(ctx, &managedKeys, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	currentTags := make(map[string]string)
	for _, tag := range output.Tags {
		if _, managed := managedKeys[*tag.Key]; managed {
			currentTags[*tag.Key] = *tag.Value
		}
	}

	tagsValue, diags := types.MapValueFrom(ctx, types.StringType, currentTags)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
	state.Tags = tagsValue

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTagResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var config quicksightTagResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var oldState quicksightTagResourceModel
	diags = req.State.Get(ctx, &oldState)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Find removed tag keys
	var oldTags map[string]string
	diags = oldState.Tags.ElementsAs(ctx, &oldTags, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var newTags map[string]string
	diags = config.Tags.ElementsAs(ctx, &newTags, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Untag removed keys
	var removedKeys []string
	for k := range oldTags {
		if _, exists := newTags[k]; !exists {
			removedKeys = append(removedKeys, k)
		}
	}
	if len(removedKeys) > 0 {
		tflog.Trace(ctx, fmt.Sprintf("UntagResource: %s keys=%v", config.ResourceArn.ValueString(), removedKeys))
		_, err := r.providerData.Quicksight.UntagResource(ctx, &quicksight.UntagResourceInput{
			ResourceArn: aws.String(config.ResourceArn.ValueString()),
			TagKeys:     removedKeys,
		})
		if err != nil {
			resp.Diagnostics.AddError("Failed to untag resource", err.Error())
			return
		}
	}

	// Apply new/updated tags
	tags := make([]qstypes.Tag, 0, len(newTags))
	for k, v := range newTags {
		tags = append(tags, qstypes.Tag{
			Key:   aws.String(k),
			Value: aws.String(v),
		})
	}

	tflog.Trace(ctx, fmt.Sprintf("TagResource: %s", config.ResourceArn.ValueString()))
	_, err := r.providerData.Quicksight.TagResource(ctx, &quicksight.TagResourceInput{
		ResourceArn: aws.String(config.ResourceArn.ValueString()),
		Tags:        tags,
	})
	if err != nil {
		resp.Diagnostics.AddError("Failed to tag resource", err.Error())
		return
	}

	diags = resp.State.Set(ctx, &config)
	resp.Diagnostics.Append(diags...)
}

func (r *quicksightTagResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state quicksightTagResourceModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var tagsMap map[string]string
	diags = state.Tags.ElementsAs(ctx, &tagsMap, false)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	keys := make([]string, 0, len(tagsMap))
	for k := range tagsMap {
		keys = append(keys, k)
	}

	tflog.Trace(ctx, fmt.Sprintf("UntagResource: %s keys=%v", state.ResourceArn.ValueString(), keys))
	_, err := r.providerData.Quicksight.UntagResource(ctx, &quicksight.UntagResourceInput{
		ResourceArn: aws.String(state.ResourceArn.ValueString()),
		TagKeys:     keys,
	})
	if err != nil {
		var notFound *qstypes.ResourceNotFoundException
		if errors.As(err, &notFound) {
			tflog.Warn(ctx, fmt.Sprintf("Resource %s not found, already deleted", state.ResourceArn.ValueString()))
			return
		}
		resp.Diagnostics.AddError("Failed to untag resource", err.Error())
		return
	}
}
