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
	_ datasource.DataSource              = &quicksightAgentDataSource{}
	_ datasource.DataSourceWithConfigure = &quicksightAgentDataSource{}
)

type quicksightAgentDataSourceModel struct {
	AgentId          types.String `tfsdk:"agent_id"`
	AwsAccountId     types.String `tfsdk:"aws_account_id"`
	Name             types.String `tfsdk:"name"`
	Description      types.String `tfsdk:"description"`
	AgentLifecycle   types.String `tfsdk:"agent_lifecycle"`
	AgentStatus      types.String `tfsdk:"agent_status"`
	WelcomeMessage   types.String `tfsdk:"welcome_message"`
	IconId           types.String `tfsdk:"icon_id"`
	StarterPrompts   types.List   `tfsdk:"starter_prompts"`
	Spaces           types.Set    `tfsdk:"spaces"`
	ActionConnectors types.List   `tfsdk:"action_connectors"`
	Arn              types.String `tfsdk:"arn"`
}

func NewQuicksightAgentDataSource() datasource.DataSource {
	return &quicksightAgentDataSource{}
}

type quicksightAgentDataSource struct {
	providerData *specifaiProviderData
}

func (d *quicksightAgentDataSource) Metadata(_ context.Context, req datasource.MetadataRequest, resp *datasource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_chatagent"
}

func (d *quicksightAgentDataSource) Schema(_ context.Context, _ datasource.SchemaRequest, resp *datasource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"agent_id": schema.StringAttribute{
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
			"agent_lifecycle": schema.StringAttribute{
				Computed: true,
			},
			"agent_status": schema.StringAttribute{
				Computed: true,
			},
			"welcome_message": schema.StringAttribute{
				Computed: true,
			},
			"icon_id": schema.StringAttribute{
				Computed: true,
			},
			"starter_prompts": schema.ListAttribute{
				Computed:    true,
				ElementType: types.StringType,
			},
			"spaces": schema.SetAttribute{
				Computed:    true,
				ElementType: types.StringType,
			},
			"action_connectors": schema.ListAttribute{
				Computed:    true,
				ElementType: types.StringType,
			},
			"arn": schema.StringAttribute{
				Computed: true,
			},
		},
	}
}

func (d *quicksightAgentDataSource) Read(ctx context.Context, req datasource.ReadRequest, resp *datasource.ReadResponse) {
	var config quicksightAgentDataSourceModel
	diags := req.Config.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	awsAccountId := aws.String(d.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	tflog.Debug(ctx, fmt.Sprintf("DescribeAgent: %s", config.AgentId.ValueString()))
	out, err := d.providerData.Quicksight.DescribeAgent(ctx, &quicksight.DescribeAgentInput{
		AwsAccountId: awsAccountId,
		AgentId:      aws.String(config.AgentId.ValueString()),
	})
	if err != nil {
		resp.Diagnostics.AddError("Unable to read agent", err.Error())
		return
	}

	var state quicksightAgentDataSourceModel
	state.AgentId = config.AgentId
	state.AwsAccountId = types.StringValue(*awsAccountId)

	if out.Agent != nil {
		state.Name = types.StringValue(*out.Agent.Name)
		state.Arn = types.StringValue(*out.Agent.Arn)
		state.AgentLifecycle = types.StringValue(string(out.Agent.AgentLifecycle))
		state.AgentStatus = types.StringValue(string(out.Agent.AgentStatus))
		state.Description = MaybeStringValue(out.Agent.Description)
		state.WelcomeMessage = MaybeStringValue(out.Agent.WelcomeMessage)
		state.IconId = MaybeStringValue(out.Agent.IconId)

		if out.Agent.StarterPrompts != nil {
			prompts, d := types.ListValueFrom(ctx, types.StringType, out.Agent.StarterPrompts)
			resp.Diagnostics.Append(d...)
			state.StarterPrompts = prompts
		} else {
			state.StarterPrompts = types.ListNull(types.StringType)
		}
		if out.Agent.Spaces != nil {
			spaces, d := types.SetValueFrom(ctx, types.StringType, out.Agent.Spaces)
			resp.Diagnostics.Append(d...)
			state.Spaces = spaces
		} else {
			state.Spaces = types.SetNull(types.StringType)
		}
		if out.Agent.ActionConnectors != nil {
			connectors, d := types.ListValueFrom(ctx, types.StringType, out.Agent.ActionConnectors)
			resp.Diagnostics.Append(d...)
			state.ActionConnectors = connectors
		} else {
			state.ActionConnectors = types.ListNull(types.StringType)
		}
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
}

func (d *quicksightAgentDataSource) Configure(_ context.Context, req datasource.ConfigureRequest, resp *datasource.ConfigureResponse) {
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
