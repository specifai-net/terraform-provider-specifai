package provider

import (
	"context"
	"fmt"
	"regexp"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/provider/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var (
	_ provider.Provider = &specifaiProvider{}
)

func New(version string) func() provider.Provider {
	return func() provider.Provider {
		return &specifaiProvider{
			version: version,
		}
	}
}

type specifaiProvider struct {
	version string
}

// hashicupsProviderModel maps provider schema data to a Go type.
type specifaiProviderModel struct {
	Region    types.String `tfsdk:"region"`
	AccountId types.String `tfsdk:"account_id"`
}

type specifaiProviderData struct {
	Quicksight *quicksight.Client
	Sts        *sts.Client
	Region     string
	AccountId  string
}

// Metadata returns the provider type name.
func (p *specifaiProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "specifai"
	resp.Version = p.version
}

// Schema defines the provider-level schema for configuration data.
func (p *specifaiProvider) Schema(_ context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"region": schema.StringAttribute{
				Optional: true,
			},
			"account_id": schema.StringAttribute{
				Optional: true,
				Validators: []validator.String{
					stringvalidator.RegexMatches(
						regexp.MustCompile(`^\d{12}$`),
						"must look like an AWS Account ID (exactly 12 digits)",
					),
				},
			},
		},
	}
}

// Configure prepares a HashiCups API client for data sources and resources.
func (p *specifaiProvider) Configure(ctx context.Context, req provider.ConfigureRequest, resp *provider.ConfigureResponse) {
	// Retrieve provider data from configuration
	var providerConfig specifaiProviderModel
	diags := req.Config.Get(ctx, &providerConfig)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// If practitioner provided a region value, it must be a known value.
	if providerConfig.Region.IsUnknown() || providerConfig.Region.ValueString() == "" {
		resp.Diagnostics.AddAttributeError(
			path.Root("region"),
			"Unknown region",
			"The provider cannot create an AWS client as there is an unknown configuration value for the region",
		)
		return
	}

	// The data to configure
	providerData := specifaiProviderData{}

	// Load the shared AWS Configuration (~/.aws/config)
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion(providerConfig.Region.ValueString()))
	if err != nil {
		resp.Diagnostics.AddError("Failed to load AWS configuration", err.Error())
		return
	}

	// Create AWS service clients
	providerData.Quicksight = quicksight.NewFromConfig(cfg, func(o *quicksight.Options) {
		o.Retryer = NewRetryer(20, 15, ctx)
	})
	providerData.Sts = sts.NewFromConfig(cfg)
	tflog.Debug(ctx, "Created AWS clients")

	// Get account details
	tflog.Debug(ctx, "Retrieving AWS account details")
	out, err := providerData.Sts.GetCallerIdentity(ctx, &sts.GetCallerIdentityInput{})
	if err != nil {
		resp.Diagnostics.AddWarning("Failed to get AWS account details", err.Error())
		providerData.AccountId = "123456789012"
	} else {
		providerData.AccountId = *out.Account
	}

	providerData.Region = cfg.Region
	tflog.Info(ctx, fmt.Sprintf("Specifai provider configured for AWS account %s in %s", providerData.AccountId, providerData.Region))

	// Make the client available during DataSource and Resource type Configure
	// methods.
	resp.DataSourceData = providerData
	resp.ResourceData = providerData
}

// DataSources defines the data sources implemented in the provider.
func (p *specifaiProvider) DataSources(_ context.Context) []func() datasource.DataSource {
	return []func() datasource.DataSource{
		NewQuicksightDashboardDataSource,
		NewnormalizedDashboardDefinitionDataSource,
	}
}

// Resources defines the resources implemented in the provider.
func (p *specifaiProvider) Resources(_ context.Context) []func() resource.Resource {
	return []func() resource.Resource{
		NewQuicksightDashboardResource,
		NewQuicksightDashboardPermissionResource,
	}
}
