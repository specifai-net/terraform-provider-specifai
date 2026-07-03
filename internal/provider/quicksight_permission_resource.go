package provider

import (
	"context"
	"errors"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/aws"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/tfsdk"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

// permissionModel is a normalized, resource-agnostic view of a permission resource's state.
type permissionModel struct {
	ResourceId   string
	AwsAccountId types.String
	Principal    types.String
	Actions      types.Set
}

// permissionAdapter maps between the framework state/plan and permissionModel.
// Each resource provides its own implementation via closures.
type permissionAdapter struct {
	resourceIdAttr string
	fromState      func(ctx context.Context, state tfsdk.State) (permissionModel, diag.Diagnostics)
	fromPlan       func(ctx context.Context, plan tfsdk.Plan) (permissionModel, diag.Diagnostics)
	toState        func(ctx context.Context, m permissionModel, state *tfsdk.State) diag.Diagnostics
}

// permissionOps holds the resource-specific QuickSight API calls.
type permissionOps struct {
	typeName string
	describe func(ctx context.Context, accountId, resourceId string) ([]qstypes.ResourcePermission, error)
	update   func(ctx context.Context, accountId, resourceId string, grant, revoke []qstypes.ResourcePermission) error
}

type permissionOpsFactory func(data *specifaiProviderData) permissionOps

type quicksightPermissionResource struct {
	providerData *specifaiProviderData
	opsFactory   permissionOpsFactory
	ops          *permissionOps
	adapter      permissionAdapter
	tfTypeSuffix string
}

var (
	_ resource.Resource              = &quicksightPermissionResource{}
	_ resource.ResourceWithConfigure = &quicksightPermissionResource{}
)

func (r *quicksightPermissionResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_quicksight_" + r.tfTypeSuffix
}

func (r *quicksightPermissionResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			r.adapter.resourceIdAttr: schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"aws_account_id": schema.StringAttribute{
				Optional: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"principal": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"actions": schema.SetAttribute{
				ElementType: types.StringType,
				Required:    true,
			},
		},
	}
}

func (r *quicksightPermissionResource) Configure(_ context.Context, req resource.ConfigureRequest, resp *resource.ConfigureResponse) {
	if req.ProviderData == nil {
		return
	}
	providerData, ok := req.ProviderData.(specifaiProviderData)
	if !ok {
		resp.Diagnostics.AddError("Unexpected Resource Configure Type", fmt.Sprintf("Expected specifaiProviderData, got: %T", req.ProviderData))
		return
	}
	r.providerData = &providerData
	ops := r.opsFactory(r.providerData)
	r.ops = &ops
}

func (r *quicksightPermissionResource) resolveAccountId(configured types.String) string {
	if configured.ValueString() != "" {
		return configured.ValueString()
	}
	return r.providerData.AccountId
}

func (r *quicksightPermissionResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	m, diags := r.adapter.fromPlan(ctx, req.Plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	accountId := r.resolveAccountId(m.AwsAccountId)
	var actions []string
	resp.Diagnostics.Append(m.Actions.ElementsAs(ctx, &actions, false)...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("Update%sPermissions (Create): %s", r.ops.typeName, m.ResourceId))
	if err := retryOnConflict(ctx, func() error {
		return r.ops.update(ctx, accountId, m.ResourceId,
			[]qstypes.ResourcePermission{{Principal: aws.String(m.Principal.ValueString()), Actions: actions}},
			nil,
		)
	}); err != nil {
		resp.Diagnostics.AddError("Failed to create permission", err.Error())
		return
	}

	resp.Diagnostics.Append(r.adapter.toState(ctx, m, &resp.State)...)
}

func (r *quicksightPermissionResource) Read(ctx context.Context, req resource.ReadRequest, resp *resource.ReadResponse) {
	m, diags := r.adapter.fromState(ctx, req.State)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	accountId := r.resolveAccountId(m.AwsAccountId)
	permissions, err := r.ops.describe(ctx, accountId, m.ResourceId)
	if err != nil {
		var notFoundErr *qstypes.ResourceNotFoundException
		if errors.As(err, &notFoundErr) {
			resp.State.RemoveResource(ctx)
			return
		}
		resp.Diagnostics.AddError("Unable to read permissions", err.Error())
		return
	}

	var found *qstypes.ResourcePermission
	for _, perm := range permissions {
		if *perm.Principal == m.Principal.ValueString() {
			found = &perm
			break
		}
	}
	if found == nil {
		resp.State.RemoveResource(ctx)
		return
	}

	actions, diags2 := types.SetValueFrom(ctx, types.StringType, found.Actions)
	resp.Diagnostics.Append(diags2...)
	if resp.Diagnostics.HasError() {
		return
	}
	m.Actions = actions
	resp.Diagnostics.Append(r.adapter.toState(ctx, m, &resp.State)...)
}

func (r *quicksightPermissionResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	m, diags := r.adapter.fromPlan(ctx, req.Plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	accountId := r.resolveAccountId(m.AwsAccountId)
	var actions []string
	resp.Diagnostics.Append(m.Actions.ElementsAs(ctx, &actions, false)...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("Update%sPermissions (Update): %s", r.ops.typeName, m.ResourceId))
	if err := retryOnConflict(ctx, func() error {
		return r.ops.update(ctx, accountId, m.ResourceId,
			[]qstypes.ResourcePermission{{Principal: aws.String(m.Principal.ValueString()), Actions: actions}},
			nil,
		)
	}); err != nil {
		resp.Diagnostics.AddError("Failed to update permission", err.Error())
		return
	}

	resp.Diagnostics.Append(r.adapter.toState(ctx, m, &resp.State)...)
}

func (r *quicksightPermissionResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	m, diags := r.adapter.fromState(ctx, req.State)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	accountId := r.resolveAccountId(m.AwsAccountId)
	var actions []string
	resp.Diagnostics.Append(m.Actions.ElementsAs(ctx, &actions, false)...)
	if resp.Diagnostics.HasError() {
		return
	}

	tflog.Trace(ctx, fmt.Sprintf("Update%sPermissions (Delete): %s", r.ops.typeName, m.ResourceId))
	if err := retryOnConflict(ctx, func() error {
		return r.ops.update(ctx, accountId, m.ResourceId,
			nil,
			[]qstypes.ResourcePermission{{Principal: aws.String(m.Principal.ValueString()), Actions: actions}},
		)
	}); err != nil {
		resp.Diagnostics.AddError("Failed to delete permission", err.Error())
	}
}
