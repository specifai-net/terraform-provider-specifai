package provider

import (
	"context"
	"encoding/json"
	"fmt"
	"slices"
	"strings"

	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-framework/types/basetypes"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

type NotFoundError struct{}

func (m *NotFoundError) Error() string {
	return "not-found"
}

func GetDashboard(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string) (*qstypes.Dashboard, error) {
	describeDashboardInput := &quicksight.DescribeDashboardInput{
		DashboardId:  dashboardId,
		AwsAccountId: awsAccountId,
	}

	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboard: %v", describeDashboardInput))
	out, err := quicksightClient.DescribeDashboard(ctx, describeDashboardInput)
	if err != nil {
		return nil, err
	} else if out == nil || out.Dashboard == nil {
		return nil, &NotFoundError{}
	}

	return out.Dashboard, nil
}

func GetDashboardDefinitionAndPermissions(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string) (*qstypes.Dashboard, *qstypes.DashboardVersionDefinition, []qstypes.ResourcePermission, error) {
	dashboard, err := GetDashboard(ctx, quicksightClient, dashboardId, awsAccountId)
	if err != nil {
		return nil, nil, nil, err
	}

	describeDashboardDefinitionInput := &quicksight.DescribeDashboardDefinitionInput{
		DashboardId:  dashboardId,
		AwsAccountId: awsAccountId,
	}
	describeDashboardPermissionsInput := &quicksight.DescribeDashboardPermissionsInput{
		DashboardId:  dashboardId,
		AwsAccountId: awsAccountId,
	}

	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboardDefinition: %v", describeDashboardDefinitionInput))
	definition, err := quicksightClient.DescribeDashboardDefinition(ctx, describeDashboardDefinitionInput)
	if err != nil {
		return nil, nil, nil, err
	} else if definition == nil || definition.Definition == nil {
		return nil, nil, nil, &NotFoundError{}
	}

	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboardPermissions: %v", describeDashboardPermissionsInput))
	permissions, err := quicksightClient.DescribeDashboardPermissions(ctx, describeDashboardPermissionsInput)
	if err != nil {
		return nil, nil, nil, err
	} else if permissions == nil {
		return nil, nil, nil, &NotFoundError{}
	}

	return dashboard, definition.Definition, permissions.Permissions, nil
}

func MaybeStringValue(value *string) basetypes.StringValue {
	if value == nil {
		return basetypes.NewStringNull()
	} else {
		return types.StringValue(*value)
	}
}

func JsonToNormalizedDefinitionJson(bytes []byte) (string, error) {
	if definition, err := JsonToNormalizedDefinition(bytes); err == nil {
		return DefinitionToNormalizedJson(&definition)
	} else {
		return "", err
	}
}

func JsonToNormalizedDefinition(bytes []byte) (qstypes.DashboardVersionDefinition, error) {
	var definition qstypes.DashboardVersionDefinition

	if err := json.Unmarshal(bytes, &definition); err != nil {
		return definition, err
	}

	NormalizeDefinition(&definition)

	return definition, nil
}

func DefinitionToNormalizedJson(definition *qstypes.DashboardVersionDefinition) (string, error) {
	var bytes []byte
	var err error
	var cloned qstypes.DashboardVersionDefinition
	var anonymous interface{}

	if definition == nil {
		return "", fmt.Errorf("unexpected nil definition")
	}

	bytes, err = json.Marshal(definition)
	if err != nil {
		return "", err
	}

	cloned, err = JsonToNormalizedDefinition(bytes)
	if err != nil {
		return "", err
	}

	bytes, err = json.Marshal(&cloned)
	if err != nil {
		return "", err
	}

	dec := json.NewDecoder(strings.NewReader(string(bytes)))
	dec.UseNumber()

	if err := DecodeJsonIntoStruct(bytes, &anonymous); err != nil {
		return "", err
	}

	bytes, err = json.Marshal(&anonymous)
	if err != nil {
		return "", err
	}

	return string(bytes), nil
}

func NormalizeDefinition(definition *qstypes.DashboardVersionDefinition) {
	if definition != nil {
		// Sort columns configurations
		if len(definition.ColumnConfigurations) > 0 {
			slices.SortFunc(definition.ColumnConfigurations, func(a, b qstypes.ColumnConfiguration) int {
				if n := SafeStringCompare(a.Column.DataSetIdentifier, b.Column.DataSetIdentifier); n != 0 {
					return n
				} else {
					return SafeStringCompare(a.Column.ColumnName, b.Column.ColumnName)
				}
			})
		}
	}
}

func DecodeJsonIntoStruct(bytes []byte, target *interface{}) error {
	dec := json.NewDecoder(strings.NewReader(string(bytes)))
	dec.UseNumber()

	if err := dec.Decode(&target); err != nil {
		return err
	}

	return nil
}

func SafeStringCompare(a, b *string) int {
	if a == nil {
		return -1
	} else if b == nil {
		return 1
	} else {
		return strings.Compare(*a, *b)
	}
}
