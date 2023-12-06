package provider

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework-jsontypes/jsontypes"
	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
)

var (
	_ datasource.DataSource = &normalizedDashboardDefinitionDataSource{}
)

type normalizedDashboardDefinitionDataSourceModel struct {
	Definition           jsontypes.Normalized `tfsdk:"definition"`
	NormalizedDefinition jsontypes.Normalized `tfsdk:"normalized_definition"`
}

func NewnormalizedDashboardDefinitionDataSource() datasource.DataSource {
	return &normalizedDashboardDefinitionDataSource{}
}

type normalizedDashboardDefinitionDataSource struct {
}

func (d *normalizedDashboardDefinitionDataSource) Metadata(_ context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_normalized_dashboard_definition"
}

func (d *normalizedDashboardDefinitionDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"definition": schema.StringAttribute{
				Required:   true,
				CustomType: jsontypes.NormalizedType{},
			},
			"normalized_definition": schema.StringAttribute{
				Computed:   true,
				CustomType: jsontypes.NormalizedType{},
			},
		},
	}
}

func (d *normalizedDashboardDefinitionDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var config normalizedDashboardDefinitionDataSourceModel
	var state normalizedDashboardDefinitionDataSourceModel

	// Get the config
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Set state
	state.Definition = config.Definition
	if normalized, err := JsonToNormalizedDefinitionJson([]byte(config.Definition.ValueString())); err == nil {
		state.NormalizedDefinition = jsontypes.NewNormalizedPointerValue(&normalized)
	} else {
		resp.Diagnostics.AddError("Failed to normalize definition", err.Error())
	}
	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}
