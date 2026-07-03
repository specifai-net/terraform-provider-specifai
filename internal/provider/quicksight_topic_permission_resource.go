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

type quicksightTopicPermissionResourceModel struct {
	TopicId      types.String `tfsdk:"topic_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Principal    types.String `tfsdk:"principal"`
	Actions      types.Set    `tfsdk:"actions"`
}

func topicPermissionAdapter() permissionAdapter {
	fromState := func(ctx context.Context, s tfsdk.State) (permissionModel, diag.Diagnostics) {
		var m quicksightTopicPermissionResourceModel
		diags := s.Get(ctx, &m)
		return permissionModel{ResourceId: m.TopicId.ValueString(), AwsAccountId: m.AwsAccountId, Principal: m.Principal, Actions: m.Actions}, diags
	}
	return permissionAdapter{
		resourceIdAttr: "topic_id",
		fromState:      fromState,
		fromPlan: func(ctx context.Context, p tfsdk.Plan) (permissionModel, diag.Diagnostics) {
			var m quicksightTopicPermissionResourceModel
			diags := p.Get(ctx, &m)
			return permissionModel{ResourceId: m.TopicId.ValueString(), AwsAccountId: m.AwsAccountId, Principal: m.Principal, Actions: m.Actions}, diags
		},
		toState: func(ctx context.Context, pm permissionModel, s *tfsdk.State) diag.Diagnostics {
			return s.Set(ctx, quicksightTopicPermissionResourceModel{
				TopicId:      types.StringValue(pm.ResourceId),
				AwsAccountId: pm.AwsAccountId,
				Principal:    pm.Principal,
				Actions:      pm.Actions,
			})
		},
	}
}

func NewQuicksightTopicPermissionResource() resource.Resource {
	return &quicksightPermissionResource{
		tfTypeSuffix: "topic_permission",
		adapter:      topicPermissionAdapter(),
		opsFactory: func(data *specifaiProviderData) permissionOps {
			return permissionOps{
				typeName: "Topic",
				describe: func(ctx context.Context, accountId, id string) ([]qstypes.ResourcePermission, error) {
					out, err := data.Quicksight.DescribeTopicPermissions(ctx, &quicksight.DescribeTopicPermissionsInput{
						AwsAccountId: aws.String(accountId),
						TopicId:      aws.String(id),
					})
					if err != nil {
						return nil, err
					}
					return out.Permissions, nil
				},
				update: func(ctx context.Context, accountId, id string, grant, revoke []qstypes.ResourcePermission) error {
					_, err := data.Quicksight.UpdateTopicPermissions(ctx, &quicksight.UpdateTopicPermissionsInput{
						AwsAccountId:      aws.String(accountId),
						TopicId:           aws.String(id),
						GrantPermissions:  grant,
						RevokePermissions: revoke,
					})
					return err
				},
			}
		},
	}
}
