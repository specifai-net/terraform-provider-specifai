package provider

import (
	"context"
	"fmt"
	"regexp"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var (
	_ datasource.DataSource              = &quicksightDashboardDataSource{}
	_ datasource.DataSourceWithConfigure = &quicksightDashboardDataSource{}
)

type quicksightDashboardModel struct {
	DashboardId       types.String `tfsdk:"dashboard_id"`
	AwsAccountId      types.String `tfsdk:"aws_account_id"`
	Name              types.String `tfsdk:"name"`
	Arn               types.String `tfsdk:"arn"`
	CreatedTime       types.String `tfsdk:"created_time"`
	LastUpdatedTime   types.String `tfsdk:"last_updated_time"`
	LastPublishedTime types.String `tfsdk:"last_published_time"`
	Status            types.String `tfsdk:"status"`
	VersionNumber     types.Int64  `tfsdk:"version_number"`
}

func NewQuicksightDashboardDataSource() datasource.DataSource {
	return &quicksightDashboardDataSource{}
}

type quicksightDashboardDataSource struct {
	providerData *specifaiProviderData
}

func (d *quicksightDashboardDataSource) Metadata(_ context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_dashboard"
}

func (d *quicksightDashboardDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"dashboard_id": schema.StringAttribute{
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
			"arn": schema.StringAttribute{
				Computed: true,
			},
			"created_time": schema.StringAttribute{
				Computed: true,
			},
			"last_updated_time": schema.StringAttribute{
				Computed: true,
			},
			"last_published_time": schema.StringAttribute{
				Computed: true,
			},
			"status": schema.StringAttribute{
				Computed: true,
			},
			"version_number": schema.Int64Attribute{
				Computed: true,
			},
		},
	}
}

func (d *quicksightDashboardDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var config quicksightDashboardModel
	var state quicksightDashboardModel

	// Get the config
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Request parameters
	describeDashboardInput := &quicksight.DescribeDashboardInput{}
	describeDashboardInput.DashboardId = aws.String(config.DashboardId.ValueString())
	describeDashboardInput.AwsAccountId = aws.String(d.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		describeDashboardInput.AwsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Do request
	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboard: %v", config))
	out, err := d.providerData.Quicksight.DescribeDashboard(ctx, describeDashboardInput)
	if err != nil {
		resp.Diagnostics.AddError("Unable to read dashboard", err.Error())
		return
	}

	// Set state
	state.DashboardId = types.StringValue(*out.Dashboard.DashboardId)
	state.AwsAccountId = types.StringValue(*describeDashboardInput.AwsAccountId)
	state.Name = types.StringValue(*out.Dashboard.Name)
	state.Arn = types.StringValue(*out.Dashboard.Arn)
	state.CreatedTime = types.StringValue(out.Dashboard.CreatedTime.Format(time.RFC3339))
	state.LastUpdatedTime = types.StringValue(out.Dashboard.LastUpdatedTime.Format(time.RFC3339))
	state.LastPublishedTime = types.StringValue(out.Dashboard.LastPublishedTime.Format(time.RFC3339))
	state.Status = types.StringValue(string(out.Dashboard.Version.Status))
	state.VersionNumber = types.Int64Value(*out.Dashboard.Version.VersionNumber)
	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Configure adds the provider configured client to the data source.
func (d *quicksightDashboardDataSource) Configure(_ context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
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
