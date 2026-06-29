package provider

import (
	"context"
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
	_ datasource.DataSource              = &quicksightSpaceDataSource{}
	_ datasource.DataSourceWithConfigure = &quicksightSpaceDataSource{}
)

type quicksightSpaceDataSourceModel struct {
	SpaceId      types.String `tfsdk:"space_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Name         types.String `tfsdk:"name"`
	Description  types.String `tfsdk:"description"`
	Arn          types.String `tfsdk:"arn"`
}

func NewQuicksightSpaceDataSource() datasource.DataSource {
	return &quicksightSpaceDataSource{}
}

type quicksightSpaceDataSource struct {
	providerData *specifaiProviderData
}

func (d *quicksightSpaceDataSource) Metadata(_ context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_space"
}

func (d *quicksightSpaceDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"space_id": schema.StringAttribute{
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
			"arn": schema.StringAttribute{
				Computed: true,
			},
		},
	}
}

func (d *quicksightSpaceDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var config quicksightSpaceDataSourceModel
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(d.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	tflog.Debug(ctx, fmt.Sprintf("DescribeSpace: %s", config.SpaceId.ValueString()))
	out, err := d.providerData.Quicksight.DescribeSpace(ctx, &quicksight.DescribeSpaceInput{
		AwsAccountId: awsAccountId,
		SpaceId:      aws.String(config.SpaceId.ValueString()),
	})
	if err != nil {
		resp.Diagnostics.AddError("Unable to read space", err.Error())
		return
	}

	var state quicksightSpaceDataSourceModel
	state.SpaceId = config.SpaceId
	state.AwsAccountId = types.StringValue(*awsAccountId)

	if out.SpaceArn != nil {
		state.Arn = types.StringValue(*out.SpaceArn)
	}
	if out.Space != nil {
		state.Name = MaybeStringValue(out.Space.Name)
		state.Description = MaybeStringValue(out.Space.Description)
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (d *quicksightSpaceDataSource) Configure(_ context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
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
