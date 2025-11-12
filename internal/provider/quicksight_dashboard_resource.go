package provider

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework-jsontypes/jsontypes"
	"github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/schema/validator"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
	"github.com/yudai/gojsondiff"
	"github.com/yudai/gojsondiff/formatter"
)

// Ensure the implementation satisfies the expected interfaces.
var (
	_ resource.Resource              = &quicksightDashboardResource{}
	_ resource.ResourceWithConfigure = &quicksightDashboardResource{}
)

type quicksightDashboardResourceModel struct {
	DashboardId        types.String         `tfsdk:"dashboard_id"`
	AwsAccountId       types.String         `tfsdk:"aws_account_id"`
	Name               types.String         `tfsdk:"name"`
	Arn                types.String         `tfsdk:"arn"`
	Definition         jsontypes.Normalized `tfsdk:"definition"`
	CreatedTime        types.String         `tfsdk:"created_time"`
	LastUpdatedTime    types.String         `tfsdk:"last_updated_time"`
	LastPublishedTime  types.String         `tfsdk:"last_published_time"`
	Status             types.String         `tfsdk:"status"`
	VersionNumber      types.Int64          `tfsdk:"version_number"`
	VersionDescription types.String         `tfsdk:"version_description"`
}

// NewQuicksightDashboardResource is a helper function to simplify the provider implementation.
func NewQuicksightDashboardResource() resource.Resource {
	return &quicksightDashboardResource{}
}

// quicksightDashboardResource is the resource implementation.
type quicksightDashboardResource struct {
	providerData *specifaiProviderData
}

// Our hard-coded default dashboard publish options.
var dashboardPublishOptions = &qstypes.DashboardPublishOptions{
	AdHocFilteringOption: &qstypes.AdHocFilteringOption{
		AvailabilityStatus: qstypes.DashboardBehaviorDisabled,
	},
	ExportToCSVOption: &qstypes.ExportToCSVOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
	SheetControlsOption: &qstypes.SheetControlsOption{
		VisibilityState: qstypes.DashboardUIStateCollapsed,
	},
	VisualPublishOptions: &qstypes.DashboardVisualPublishOptions{
		ExportHiddenFieldsOption: &qstypes.ExportHiddenFieldsOption{
			AvailabilityStatus: qstypes.DashboardBehaviorDisabled,
		},
	},
	SheetLayoutElementMaximizationOption: &qstypes.SheetLayoutElementMaximizationOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
	VisualMenuOption: &qstypes.VisualMenuOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
	VisualAxisSortOption: &qstypes.VisualAxisSortOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
	ExportWithHiddenFieldsOption: &qstypes.ExportWithHiddenFieldsOption{
		AvailabilityStatus: qstypes.DashboardBehaviorDisabled,
	},
	DataPointDrillUpDownOption: &qstypes.DataPointDrillUpDownOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
	DataPointMenuLabelOption: &qstypes.DataPointMenuLabelOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
	DataPointTooltipOption: &qstypes.DataPointTooltipOption{
		AvailabilityStatus: qstypes.DashboardBehaviorEnabled,
	},
}

// Metadata returns the resource type name.
func (r *quicksightDashboardResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_dashboard"
}

// Schema defines the schema for the resource.
func (r *quicksightDashboardResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"dashboard_id": schema.StringAttribute{
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
				Validators: []validator.String{
					stringvalidator.LengthBetween(1, 2048),
				},
			},
			"arn": schema.StringAttribute{
				Computed: true,
			},
			"definition": schema.StringAttribute{
				Required:   true,
				CustomType: jsontypes.NormalizedType{},
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
			"version_description": schema.StringAttribute{
				Required: true,
				Validators: []validator.String{
					stringvalidator.LengthBetween(1, 512),
				},
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
		},
	}
}

// Create creates the resource and sets the initial Terraform state.
func (r *quicksightDashboardResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Request parameters
	createDashboardInput := &quicksight.CreateDashboardInput{}
	createDashboardInput.DashboardId = aws.String(config.DashboardId.ValueString())
	createDashboardInput.AwsAccountId = aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		createDashboardInput.AwsAccountId = aws.String(config.AwsAccountId.ValueString())
	}
	createDashboardInput.Name = aws.String(config.Name.ValueString())
	createDashboardInput.VersionDescription = aws.String((config.VersionDescription.ValueString()))
	if definition, err := JsonToNormalizedDefinition([]byte(config.Definition.ValueString())); err == nil {
		createDashboardInput.Definition = &definition
	} else {
		resp.Diagnostics.AddError("Invalid definition", err.Error())
	}
	createDashboardInput.ValidationStrategy = &qstypes.ValidationStrategy{Mode: qstypes.ValidationStrategyModeLenient}
	createDashboardInput.DashboardPublishOptions = dashboardPublishOptions

	// Do request
	tflog.Trace(ctx, fmt.Sprintf("CreateDashboard: %v", config))
	out, err := r.providerData.Quicksight.CreateDashboard(ctx, createDashboardInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create dashboard", err.Error())
		return
	}
	tflog.Debug(ctx, fmt.Sprintf("CreateDashboard returned %d", out.Status))

	// Wait until dashboard has been created
	dashboard, err := WaitForDashboardCreation(ctx, r.providerData.Quicksight, createDashboardInput.DashboardId, createDashboardInput.AwsAccountId, nil)
	if err != nil {
		resp.Diagnostics.AddError("Failed to create dashboard", err.Error())
		return
	}

	// Handle dashboard creation errors
	if dashboard.Version.Status == qstypes.ResourceStatusCreationFailed {
		// Emit creation errors
		message := fmt.Sprintf("Dashboard creation failed due to %d problems", len(dashboard.Version.Errors))
		for _, err := range dashboard.Version.Errors {
			message += "\n"
			message += *err.Message
		}
		resp.Diagnostics.AddError("Failed to create dashboard", message)

		// Delete the failed dashboard
		err := DeleteDashboard(ctx, r.providerData.Quicksight, createDashboardInput.DashboardId, createDashboardInput.AwsAccountId, nil)
		if err != nil {
			resp.Diagnostics.AddError("Failed to delete dashboard", err.Error())
		}

		return
	} else if dashboard.Version.Status != qstypes.ResourceStatusCreationSuccessful {
		panic("Unexpected dashboard status")
	}

	// Read back the dashboard into the state
	var state quicksightDashboardResourceModel
	err = ReadDashboardIntoResourceModel(ctx, r.providerData.Quicksight, createDashboardInput.DashboardId, createDashboardInput.AwsAccountId, nil, &state)
	if err != nil {
		resp.Diagnostics.AddError("Failed to read back dashboard", err.Error())
	}

	// Our definition may not match what was return from quicksight which
	// generally means our definition is out of date and needs to be updated.
	// Here we compare the two and emit some diagnostic warnings when there are
	// differences. This is not a problem, just a trigger to update our
	// definition.
	WarnForDefinitionDifferences([]byte(*config.Definition.ValueStringPointer()), []byte(*state.Definition.ValueStringPointer()), &resp.Diagnostics)

	// Set the state definition back to the original configured string because
	// this is what terraform requires.
	//
	// See:
	// https://developer.hashicorp.com/terraform/plugin/framework/resources/plan-modification#terraform-data-consistency-rules
	state.Definition = config.Definition

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Read refreshes the Terraform state with the latest data.
func (r *quicksightDashboardResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardResourceModel
	var state quicksightDashboardResourceModel
	diags := req.State.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Account id fallback
	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Read back the dashboard into the state
	state = config
	err := ReadDashboardIntoResourceModel(ctx, r.providerData.Quicksight, aws.String(config.DashboardId.ValueString()), awsAccountId, nil, &state)
	if err != nil {
		if errors.As(err, &NOT_FOUND_ERROR) {
			resp.Diagnostics.AddWarning("Dashboard not found, removing from state", err.Error())
			resp.State.RemoveResource(ctx)
		} else {
			resp.Diagnostics.AddError("Unable to read dashboard", err.Error())
		}
		return
	}

	// The definition we read back from quicksight may be slightly different
	// from the JSON that is configured but could be semantically the same.
	// If this is the case we just return the configured JSON so we don't
	// trigger a useless update. We also warn of any definition changes
	// because our definition is out of date and needs to be updated.
	if configDefinitionJson, err := JsonToNormalizedDefinitionJson([]byte(*config.Definition.ValueStringPointer())); err == nil {
		if stateDefinitionJson, err := JsonToNormalizedDefinitionJson([]byte(*state.Definition.ValueStringPointer())); err == nil {
			if configDefinitionJson == stateDefinitionJson {
				WarnForDefinitionDifferences([]byte(configDefinitionJson), []byte(stateDefinitionJson), &resp.Diagnostics)
				state.Definition = config.Definition
			}
		} else {
			diags.AddWarning("Definition compare failed", err.Error())
		}
	} else {
		diags.AddWarning("Definition compare failed", err.Error())
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Update updates the resource and sets the updated Terraform state on success.
func (r *quicksightDashboardResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardResourceModel
	diags := req.Plan.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Extract the current definition state so we can check after the update if
	// something actually changed or that our definition/sdk is just slightly
	// out of date comapred to quicksight. We can detect this by doing the
	// update and then comparing the "updated" definition to this.
	var beforeState quicksightDashboardResourceModel
	diags = req.State.Get(ctx, &beforeState)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Request parameters
	updateDashboardInput := &quicksight.UpdateDashboardInput{}
	updateDashboardInput.DashboardId = aws.String(config.DashboardId.ValueString())
	updateDashboardInput.AwsAccountId = aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		updateDashboardInput.AwsAccountId = aws.String(config.AwsAccountId.ValueString())
	}
	updateDashboardInput.Name = aws.String(config.Name.ValueString())
	updateDashboardInput.VersionDescription = aws.String((config.VersionDescription.ValueString()))
	if definition, err := JsonToNormalizedDefinition([]byte(config.Definition.ValueString())); err == nil {
		updateDashboardInput.Definition = &definition
	} else {
		resp.Diagnostics.AddError("Invalid definition", err.Error())
	}
	updateDashboardInput.ValidationStrategy = &qstypes.ValidationStrategy{Mode: qstypes.ValidationStrategyModeLenient}
	updateDashboardInput.DashboardPublishOptions = dashboardPublishOptions

	// Do update request
	tflog.Trace(ctx, fmt.Sprintf("UpdateDashboard: %v", config))
	out, err := r.providerData.Quicksight.UpdateDashboard(ctx, updateDashboardInput)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update dashboard", err.Error())
		return
	}
	tflog.Debug(ctx, fmt.Sprintf("UpdateDashboard returned %d", out.Status))

	// Update does not return the version number so we need to find it via list
	// dashboard versions.
	version, err := FindDashboardVersion(ctx, r.providerData.Quicksight, updateDashboardInput.DashboardId, updateDashboardInput.AwsAccountId, out.VersionArn)
	if err != nil {
		// Fail to find the version which should not happen, but if we do reach
		// here we are left with a version that we can't delete. And we also
		// can't continue.
		resp.Diagnostics.AddError("Failed to find dashboard version", err.Error())
		return
	}

	// Wait until dashboard has been created
	dashboard, err := WaitForDashboardCreation(ctx, r.providerData.Quicksight, updateDashboardInput.DashboardId, updateDashboardInput.AwsAccountId, version.VersionNumber)
	if err != nil {
		resp.Diagnostics.AddError("Failed to update dashboard", err.Error())
		return
	}

	// Update failed, remove the broken version and exit.
	if dashboard.Version.Status == qstypes.ResourceStatusCreationFailed {
		// Emit update errors
		message := fmt.Sprintf("Dashboard update failed due to %d problems", len(dashboard.Version.Errors))
		for _, err := range dashboard.Version.Errors {
			message += "\n"
			message += *err.Message
		}
		resp.Diagnostics.AddError("Failed to update dashboard", message)

		// Delete the failed dashboard
		err := DeleteDashboard(ctx, r.providerData.Quicksight, updateDashboardInput.DashboardId, updateDashboardInput.AwsAccountId, dashboard.Version.VersionNumber)
		if err != nil {
			resp.Diagnostics.AddError("Failed to delete dashboard version", err.Error())
		}

		return
	} else if dashboard.Version.Status != qstypes.ResourceStatusCreationSuccessful {
		panic("Unexpected dashboard status")
	}

	// Read back the dashboard into the afterState
	var afterState quicksightDashboardResourceModel
	err = ReadDashboardIntoResourceModel(ctx, r.providerData.Quicksight, updateDashboardInput.DashboardId, updateDashboardInput.AwsAccountId, version.VersionNumber, &afterState)
	if err != nil {
		resp.Diagnostics.AddError("Failed to read back dashboard", err.Error())
	}

	// Check if something actually changed before updating the published version.
	var nameChanged = strings.Compare(beforeState.Name.String(), afterState.Name.String()) != 0
	var definitionChanged = strings.Compare(beforeState.Definition.String(), afterState.Definition.String()) != 0
	var versionDescriptionChanged = strings.Compare(beforeState.VersionDescription.String(), afterState.VersionDescription.String()) != 0

	// Here we compare the before and after state of the dashboard and if they
	// are the same (because our definition and/or sdk do not exactly match what
	// quicksight currently returns) we skip updating the published version and
	// delete the updated version.
	if nameChanged || definitionChanged || versionDescriptionChanged {
		// Update succeeded, now we set it to the published version
		updateDashboardPublishedVersionInput := &quicksight.UpdateDashboardPublishedVersionInput{}
		updateDashboardPublishedVersionInput.DashboardId = aws.String(config.DashboardId.ValueString())
		updateDashboardPublishedVersionInput.AwsAccountId = aws.String(r.providerData.AccountId)
		updateDashboardPublishedVersionInput.VersionNumber = version.VersionNumber
		tflog.Trace(ctx, fmt.Sprintf("UpdateDashboardPublishedVersion: %v", config))
		out2, err := r.providerData.Quicksight.UpdateDashboardPublishedVersion(ctx, updateDashboardPublishedVersionInput)
		if err != nil {
			resp.Diagnostics.AddError("Failed to update dashboard published version", err.Error())
			return
		}
		tflog.Debug(ctx, fmt.Sprintf("UpdateDashboardPublishedVersion returned %d", out2.Status))
	} else {
		// If we reach here, our "update" did not actually update anything so we
		// skip the publish as it won't change anything and this way we keep the
		// dashboard more stable.
		tflog.Info(ctx, "Skipping dashboard publish, there aren't actually any changes")

		//  Delete the unchanged dashboard
		err := DeleteDashboard(ctx, r.providerData.Quicksight, updateDashboardInput.DashboardId, updateDashboardInput.AwsAccountId, version.VersionNumber)
		if err != nil {
			resp.Diagnostics.AddError("Failed to delete dashboard version", err.Error())
		}

		// The cause for the non-update is probably that our definition may not
		// match what was returned from quicksight which generally means our
		// definition is out of date and needs to be updated. Here we compare
		// the two and emit some diagnostic warnings when there are differences.
		// This is not a problem, just a trigger to update our definition.
		WarnForDefinitionDifferences([]byte(*config.Definition.ValueStringPointer()), []byte(*afterState.Definition.ValueStringPointer()), &resp.Diagnostics)
	}

	// Set the state definition back to the original configured string because
	// this is what terraform requires.
	//
	// See:
	// https://developer.hashicorp.com/terraform/plugin/framework/resources/plan-modification#terraform-data-consistency-rules
	afterState.Definition = config.Definition

	diags = resp.State.Set(ctx, &afterState)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

// Delete deletes the resource and removes the Terraform state on success.
func (r *quicksightDashboardResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	// Retrieve values from the resource definition
	var config quicksightDashboardResourceModel
	diags := req.State.Get(ctx, &config)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	// Account id fallback
	awsAccountId := aws.String(r.providerData.AccountId)
	if config.AwsAccountId.ValueString() != "" {
		awsAccountId = aws.String(config.AwsAccountId.ValueString())
	}

	// Delete the dashboard
	err := DeleteDashboard(ctx, r.providerData.Quicksight, aws.String(config.DashboardId.ValueString()), awsAccountId, nil)
	if err != nil {
		resp.Diagnostics.AddError("Failed to delete dashboard", err.Error())
	}
}

// Configure adds the provider configured client to the data source.
func (d *quicksightDashboardResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	if req.ProviderData == nil {
		return
	}

	specifaiProviderData, ok := req.ProviderData.(specifaiProviderData)
	if !ok {
		resp.Diagnostics.AddError(
			"Unexpected Resource Configure Type",
			fmt.Sprintf("Expected Specifai provider data: %T", req.ProviderData),
		)
		return
	}

	d.providerData = &specifaiProviderData
}

func ReadDashboardIntoResourceModel(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, versionNumber *int64, resourceModel *quicksightDashboardResourceModel) error {
	// Get the dashboard and definition
	dashboard, definition, _, err := GetDashboardDefinitionAndPermissions(ctx, quicksightClient, dashboardId, awsAccountId, versionNumber)
	if err != nil {
		return err
	}

	resourceModel.DashboardId = types.StringValue(*dashboardId)
	resourceModel.AwsAccountId = types.StringValue(*awsAccountId)
	resourceModel.Name = MaybeStringValue(dashboard.Name)
	resourceModel.Arn = types.StringValue(*dashboard.Arn)
	if json, err := DefinitionToNormalizedJson(definition); err == nil {
		resourceModel.Definition = jsontypes.NewNormalizedPointerValue(&json)
	} else {
		return err
	}
	resourceModel.CreatedTime = types.StringValue(dashboard.CreatedTime.Format(time.RFC3339))
	resourceModel.LastUpdatedTime = types.StringValue(dashboard.LastUpdatedTime.Format(time.RFC3339))
	resourceModel.LastPublishedTime = types.StringValue(dashboard.LastPublishedTime.Format(time.RFC3339))
	resourceModel.Status = types.StringValue(string(dashboard.Version.Status))
	resourceModel.VersionNumber = types.Int64Value(*dashboard.Version.VersionNumber)
	resourceModel.VersionDescription = MaybeStringValue(dashboard.Version.Description)

	return nil
}

func WarnForDefinitionDifferences(left []byte, right []byte, diags *diag.Diagnostics) {
	differ := gojsondiff.New()
	if diff, err := differ.Compare(left, right); err == nil {
		if diff.Modified() {
			var orig interface{}
			if err := DecodeJsonIntoStruct(left, &orig); err == nil {
				// Unfortunately this formatter does not have an option the
				// limit the number of unchanged lines around the changes which
				// means this output is very verbose.
				formatter := formatter.NewAsciiFormatter(orig, formatter.AsciiFormatterConfig{
					ShowArrayIndex: false,
					Coloring:       false,
				})
				diffString, _ := formatter.Format(diff)
				diags.AddWarning("Definition outdated", fmt.Sprintf("The deployed definition differs from the configured definition. This means that after deploying quicksight returned a different definition that we gave to quicksight. This means that either our stored definition is outdated or that the quicksight sdk used by this provider is outdated.\n%s", diffString))
			} else {
				diags.AddWarning("Definition diff failed", err.Error())
			}
		}
	} else {
		diags.AddWarning("Definition diff failed", err.Error())
	}
}
