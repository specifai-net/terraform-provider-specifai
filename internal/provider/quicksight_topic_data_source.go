package provider

import (
	"context"
	"encoding/json"
	"fmt"
	"regexp"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var (
	_ datasource.DataSource              = &quicksightTopicDataSource{}
	_ datasource.DataSourceWithConfigure = &quicksightTopicDataSource{}
)

type quicksightTopicDataSourceModel struct {
	TopicId               types.String `tfsdk:"topic_id"`
	AwsAccountId          types.String `tfsdk:"aws_account_id"`
	Name                  types.String `tfsdk:"name"`
	Description           types.String `tfsdk:"description"`
	DataSets              types.String `tfsdk:"data_sets"`
	CustomInstructions    types.String `tfsdk:"custom_instructions"`
	UserExperienceVersion types.String `tfsdk:"user_experience_version"`
	Arn                   types.String `tfsdk:"arn"`
}

func NewQuicksightTopicDataSource() datasource.DataSource {
	return &quicksightTopicDataSource{}
}

type quicksightTopicDataSource struct {
	providerData *specifaiProviderData
}

func (d *quicksightTopicDataSource) Metadata(_ context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_topic"
}

func (d *quicksightTopicDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"topic_id": schema.StringAttribute{
				Required: true,
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
				Computed: true,
			},
			"description": schema.StringAttribute{
				Computed: true,
			},
			"data_sets": schema.StringAttribute{
				Computed: true,
			},
			"custom_instructions": schema.StringAttribute{
				Computed: true,
			},
			"user_experience_version": schema.StringAttribute{
				Computed: true,
			},
			"arn": schema.StringAttribute{
				Computed: true,
			},
		},
	}
}

func (d *quicksightTopicDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var config quicksightTopicDataSourceModel
	var state quicksightTopicDataSourceModel

	// Get the config
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Account id fallback
	awsAccountId := aws.String(d.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Get topic
	tflog.Debug(ctx, fmt.Sprintf("DescribeTopic: %v", config))
	describeInput := &quicksight.DescribeTopicInput{
		AwsAccountId: awsAccountId,
		TopicId:      aws.String(config.TopicId.ValueString()),
	}

	out, err := d.providerData.Quicksight.DescribeTopic(ctx, describeInput)
	if err != nil {
		resp.Diagnostics.AddError("Unable to read topic", err.Error())
		return
	}

	// Set state
	state.TopicId = types.StringValue(config.TopicId.ValueString())
	state.AwsAccountId = types.StringValue(*awsAccountId)
	state.Arn = types.StringValue(*out.Arn)

	if out.Topic != nil {
		state.Name = MaybeStringValue(out.Topic.Name)
		state.Description = MaybeStringValue(out.Topic.Description)
		state.UserExperienceVersion = types.StringValue(string(out.Topic.UserExperienceVersion))

		// Marshal datasets to JSON
		if out.Topic.DataSets != nil {
			dataSetsJSON, err := json.Marshal(out.Topic.DataSets)
			if err != nil {
				resp.Diagnostics.AddError("Failed to marshal datasets", err.Error())
				return
			}
			state.DataSets = types.StringValue(string(dataSetsJSON))
		}
	}

	if out.CustomInstructions != nil {
		state.CustomInstructions = MaybeStringValue(out.CustomInstructions.CustomInstructionsString)
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Configure adds the provider configured client to the data source.
func (d *quicksightTopicDataSource) Configure(_ context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
	if req.ProviderData == nil {
		return
	}

	specifaiProviderData, ok := req.ProviderData.(specifaiProviderData)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Data Source Configure Type",
			fmt.Sprintf("Expected Specifai provider data: %T", req.ProviderData),
		)
		return
	}

	d.providerData = &specifaiProviderData
}
