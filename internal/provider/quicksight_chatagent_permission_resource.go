package provider

import (
	"context"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/tfsdk"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

type quicksightAgentPermissionResourceModel struct {
	AgentId      types.String `tfsdk:"agent_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Principal    types.String `tfsdk:"principal"`
	Actions      types.Set    `tfsdk:"actions"`
}

func agentPermissionAdapter() permissionAdapter {
	return permissionAdapter{
		resourceIdAttr: "agent_id",
		fromState: func(ctx context.Context, s tfsdk.State) (permissionModel, diag.Diagnostics) {
			var m quicksightAgentPermissionResourceModel
			diags := s.Get(ctx, &m)
			return permissionModel{ResourceId: m.AgentId.ValueString(), AwsAccountId: m.AwsAccountId, Principal: m.Principal, Actions: m.Actions}, diags
		},
		fromPlan: func(ctx context.Context, p tfsdk.Plan) (permissionModel, diag.Diagnostics) {
			var m quicksightAgentPermissionResourceModel
			diags := p.Get(ctx, &m)
			return permissionModel{ResourceId: m.AgentId.ValueString(), AwsAccountId: m.AwsAccountId, Principal: m.Principal, Actions: m.Actions}, diags
		},
		toState: func(ctx context.Context, pm permissionModel, s *tfsdk.State) diag.Diagnostics {
			return s.Set(ctx, quicksightAgentPermissionResourceModel{
				AgentId:      types.StringValue(pm.ResourceId),
				AwsAccountId: pm.AwsAccountId,
				Principal:    pm.Principal,
				Actions:      pm.Actions,
			})
		},
	}
}

func NewQuicksightAgentPermissionResource() resource.Resource {
	return &quicksightPermissionResource{
		tfTypeSuffix: "chatagent_permission",
		adapter:      agentPermissionAdapter(),
		opsFactory: func(data *specifaiProviderData) permissionOps {
			return permissionOps{
				typeName: "Agent",
				describe: func(ctx context.Context, accountId, id string) ([]qstypes.ResourcePermission, error) {
					out, err := data.Quicksight.DescribeAgentPermissions(ctx, &quicksight.DescribeAgentPermissionsInput{
						AwsAccountId: aws.String(accountId),
						AgentId:      aws.String(id),
					})
					if err != nil {
						return nil, err
					}
					return out.Permissions, nil
				},
				update: func(ctx context.Context, accountId, id string, grant, revoke []qstypes.ResourcePermission) error {
					_, err := data.Quicksight.UpdateAgentPermissions(ctx, &quicksight.UpdateAgentPermissionsInput{
						AwsAccountId:      aws.String(accountId),
						AgentId:           aws.String(id),
						GrantPermissions:  grant,
						RevokePermissions: revoke,
					})
					return err
				},
			}
		},
	}
}
