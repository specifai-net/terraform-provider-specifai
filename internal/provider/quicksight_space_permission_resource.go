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

type quicksightSpacePermissionResourceModel struct {
	SpaceId      types.String `tfsdk:"space_id"`
	AwsAccountId types.String `tfsdk:"aws_account_id"`
	Principal    types.String `tfsdk:"principal"`
	Actions      types.Set    `tfsdk:"actions"`
}

func spacePermissionAdapter() permissionAdapter {
	return permissionAdapter{
		resourceIdAttr: "space_id",
		fromState: func(ctx context.Context, s tfsdk.State) (permissionModel, diag.Diagnostics) {
			var m quicksightSpacePermissionResourceModel
			diags := s.Get(ctx, &m)
			return permissionModel{ResourceId: m.SpaceId.ValueString(), AwsAccountId: m.AwsAccountId, Principal: m.Principal, Actions: m.Actions}, diags
		},
		fromPlan: func(ctx context.Context, p tfsdk.Plan) (permissionModel, diag.Diagnostics) {
			var m quicksightSpacePermissionResourceModel
			diags := p.Get(ctx, &m)
			return permissionModel{ResourceId: m.SpaceId.ValueString(), AwsAccountId: m.AwsAccountId, Principal: m.Principal, Actions: m.Actions}, diags
		},
		toState: func(ctx context.Context, pm permissionModel, s *tfsdk.State) diag.Diagnostics {
			return s.Set(ctx, quicksightSpacePermissionResourceModel{
				SpaceId:      types.StringValue(pm.ResourceId),
				AwsAccountId: pm.AwsAccountId,
				Principal:    pm.Principal,
				Actions:      pm.Actions,
			})
		},
	}
}

func NewQuicksightSpacePermissionResource() resource.Resource {
	return &quicksightPermissionResource{
		tfTypeSuffix: "space_permission",
		adapter:      spacePermissionAdapter(),
		opsFactory: func(data *specifaiProviderData) permissionOps {
			return permissionOps{
				typeName: "Space",
				describe: func(ctx context.Context, accountId, id string) ([]qstypes.ResourcePermission, error) {
					out, err := data.Quicksight.DescribeSpacePermissions(ctx, &quicksight.DescribeSpacePermissionsInput{
						AwsAccountId: aws.String(accountId),
						SpaceId:      aws.String(id),
					})
					if err != nil {
						return nil, err
					}
					return out.Permissions, nil
				},
				update: func(ctx context.Context, accountId, id string, grant, revoke []qstypes.ResourcePermission) error {
					_, err := data.Quicksight.UpdateSpacePermissions(ctx, &quicksight.UpdateSpacePermissionsInput{
						AwsAccountId:      aws.String(accountId),
						SpaceId:           aws.String(id),
						GrantPermissions:  grant,
						RevokePermissions: revoke,
					})
					return err
				},
			}
		},
	}
}
