package provider

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"slices"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/quicksight"
	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/cenkalti/backoff/v4"
	"github.com/hashicorp/terraform-plugin-framework/types"
	"github.com/hashicorp/terraform-plugin-framework/types/basetypes"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

type NotFoundError struct{}

func (m *NotFoundError) Error() string {
	return "not-found"
}

var NOT_FOUND_ERROR *NotFoundError

type TimeoutError struct{}

func (m *TimeoutError) Error() string {
	return "timeout"
}

func GetDashboard(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, versionNumber *int64) (*qstypes.Dashboard, error) {
	describeDashboardInput := &quicksight.DescribeDashboardInput{
		DashboardId:   dashboardId,
		AwsAccountId:  awsAccountId,
		VersionNumber: versionNumber,
	}

	tflog.Trace(ctx, fmt.Sprintf("DescribeDashboard: %v", describeDashboardInput))
	out, err := quicksightClient.DescribeDashboard(ctx, describeDashboardInput)
	if err != nil {
		tflog.Warn(ctx, fmt.Sprintf("DescribeDashboard returned: %s", err))
		return nil, &NotFoundError{}
	} else if out == nil || out.Dashboard == nil {
		tflog.Warn(ctx, fmt.Sprintf("DescribeDashboard returned: %d", out.Status))
		return nil, &NotFoundError{}
	}
	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboard returned: %d", out.Status))

	return out.Dashboard, nil
}

func FindDashboardVersion(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, versionArn *string) (*qstypes.DashboardVersionSummary, error) {
	var maxResults int32 = 100
	var nextToken *string
	for {
		listDashboardVersionsInput := &quicksight.ListDashboardVersionsInput{
			DashboardId:  dashboardId,
			AwsAccountId: awsAccountId,
			MaxResults:   &maxResults,
			NextToken:    nextToken,
		}

		tflog.Trace(ctx, fmt.Sprintf("ListDashboardVersions: %v", listDashboardVersionsInput))
		out, err := quicksightClient.ListDashboardVersions(ctx, listDashboardVersionsInput)
		if err != nil {
			tflog.Warn(ctx, fmt.Sprintf("ListDashboardVersions returned: %s", err))
			return nil, &NotFoundError{}
		} else if out == nil || out.DashboardVersionSummaryList == nil {
			tflog.Warn(ctx, fmt.Sprintf("ListDashboardVersions returned: %d", out.Status))
			return nil, &NotFoundError{}
		}

		for _, element := range out.DashboardVersionSummaryList {
			if strings.Compare(*element.Arn, *versionArn) == 0 {
				return &element, nil
			}
		}

		if out.NextToken != nil {
			nextToken = out.NextToken
		} else {
			break
		}
	}

	tflog.Debug(ctx, fmt.Sprintf("DashboardVersion not found: %s", *versionArn))

	return nil, &NotFoundError{}
}

func GetDashboardDefinitionAndPermissions(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, versionNumber *int64) (*qstypes.Dashboard, *qstypes.DashboardVersionDefinition, []qstypes.ResourcePermission, error) {
	dashboard, err := GetDashboard(ctx, quicksightClient, dashboardId, awsAccountId, versionNumber)
	if err != nil {
		return nil, nil, nil, err
	} else if dashboard == nil {
		return nil, nil, nil, nil
	}

	describeDashboardDefinitionInput := &quicksight.DescribeDashboardDefinitionInput{
		DashboardId:   dashboardId,
		AwsAccountId:  awsAccountId,
		VersionNumber: versionNumber,
	}

	describeDashboardPermissionsInput := &quicksight.DescribeDashboardPermissionsInput{
		DashboardId:  dashboardId,
		AwsAccountId: awsAccountId,
	}

	tflog.Trace(ctx, fmt.Sprintf("DescribeDashboardDefinition: %v", describeDashboardDefinitionInput))
	out1, err := quicksightClient.DescribeDashboardDefinition(ctx, describeDashboardDefinitionInput)
	if err != nil {
		tflog.Warn(ctx, fmt.Sprintf("DescribeDashboardDefinition returned: %s", err))
		return nil, nil, nil, err
	} else if out1 == nil || out1.Definition == nil {
		tflog.Warn(ctx, fmt.Sprintf("DescribeDashboardDefinition returned: %d", out1.Status))
		return nil, nil, nil, &NotFoundError{}
	}
	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboardDefinition returned: %d", out1.Status))

	tflog.Trace(ctx, fmt.Sprintf("DescribeDashboardPermissions: %v", describeDashboardPermissionsInput))
	out2, err := quicksightClient.DescribeDashboardPermissions(ctx, describeDashboardPermissionsInput)
	if err != nil {
		tflog.Warn(ctx, fmt.Sprintf("DescribeDashboardPermissions returned: %s", err))
		return nil, nil, nil, err
	} else if out2 == nil {
		tflog.Warn(ctx, fmt.Sprintf("DescribeDashboardPermissions returned: %d", out2.Status))
		return nil, nil, nil, &NotFoundError{}
	}
	tflog.Debug(ctx, fmt.Sprintf("DescribeDashboardPermissions returned: %d", out2.Status))

	return dashboard, out1.Definition, out2.Permissions, nil
}

func DeleteDashboard(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, versionNumber *int64) error {
	deleteDashboardInput := &quicksight.DeleteDashboardInput{
		DashboardId:   dashboardId,
		AwsAccountId:  awsAccountId,
		VersionNumber: versionNumber,
	}

	tflog.Trace(ctx, fmt.Sprintf("DeleteDashboard: %v", deleteDashboardInput))
	out, err := quicksightClient.DeleteDashboard(ctx, deleteDashboardInput)
	if err != nil {
		tflog.Warn(ctx, fmt.Sprintf("DeleteDashboard returned: %s", err))
		return err
	}

	tflog.Debug(ctx, fmt.Sprintf("DeleteDashboard returned: %d", out.Status))
	return nil
}

func WaitForDashboardCreation(ctx context.Context, quicksightClient *quicksight.Client, dashboardId *string, awsAccountId *string, versionNumber *int64) (*qstypes.Dashboard, error) {
	exp := backoff.NewExponentialBackOff()
	exp.InitialInterval = 1 * time.Second
	exp.Reset()
	var dashboard *qstypes.Dashboard
	for dashboard == nil || dashboard.Version.Status == qstypes.ResourceStatusCreationInProgress {
		d, err := GetDashboard(ctx, quicksightClient, dashboardId, awsAccountId, versionNumber)
		if err != nil {
			return nil, err
		}
		tflog.Debug(ctx, fmt.Sprintf("Dashboard %s status is %s", *dashboardId, d.Version.Status))
		dashboard = d
		if exp.GetElapsedTime() > 15*time.Minute {
			return nil, &TimeoutError{}
		} else {
			time.Sleep(exp.NextBackOff())
		}
	}

	if dashboard.Version.Status != qstypes.ResourceStatusCreationSuccessful && dashboard.Version.Status != qstypes.ResourceStatusCreationFailed {
		panic("Unexpected dashboard status")
	}

	return dashboard, nil
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
		// Here we sort various array field so we can compare dashboard
		// definitions in a stable manner.

		if len(definition.DataSetIdentifierDeclarations) > 1 {
			slices.SortFunc(definition.DataSetIdentifierDeclarations, func(a, b qstypes.DataSetIdentifierDeclaration) int {
				return SafeStringCompare(a.Identifier, b.Identifier)
			})
		}

		if len(definition.CalculatedFields) > 1 {
			slices.SortFunc(definition.CalculatedFields, func(a, b qstypes.CalculatedField) int {
				if n := SafeStringCompare(a.DataSetIdentifier, b.DataSetIdentifier); n != 0 {
					return n
				} else {
					return SafeStringCompare(a.Name, b.Name)
				}
			})
		}

		if len(definition.ColumnConfigurations) > 1 {
			slices.SortFunc(definition.ColumnConfigurations, func(a, b qstypes.ColumnConfiguration) int {
				if n := SafeStringCompare(a.Column.DataSetIdentifier, b.Column.DataSetIdentifier); n != 0 {
					return n
				} else {
					return SafeStringCompare(a.Column.ColumnName, b.Column.ColumnName)
				}
			})
		}

		if len(definition.FilterGroups) > 1 {
			slices.SortFunc(definition.FilterGroups, func(a, b qstypes.FilterGroup) int {
				return SafeStringCompare(a.FilterGroupId, b.FilterGroupId)
			})
		}

		// TODO: ParameterDeclarations and StaticFiles
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

func WriteToFile(filename string, variable string) error {
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer f.Close()

	_, err = f.WriteString(variable)
	return err
}
