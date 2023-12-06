// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package provider

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	qstypes "github.com/aws/aws-sdk-go-v2/service/quicksight/types"
	"github.com/hashicorp/terraform-plugin-framework/attr"
	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/types/basetypes"
	"github.com/hashicorp/terraform-plugin-go/tftypes"
)

var (
	_ basetypes.StringValuable                   = (*NormalizedDefinition)(nil)
	_ basetypes.StringValuableWithSemanticEquals = (*NormalizedDefinition)(nil)
)

// NormalizedDefinition represents a valid JSON string (RFC 7159). Semantic equality logic is defined for NormalizedDefinition
// such that inconsequential differences between JSON strings are ignored (whitespace, property order, etc). If you
// need strict, byte-for-byte, string equality, consider using ExactType.
type NormalizedDefinition struct {
	state      attr.ValueState
	definition qstypes.DashboardVersionDefinition
}

func NewNormalizedDefinitionNullValue() NormalizedDefinition {
	return NormalizedDefinition{
		state: attr.ValueStateNull,
	}
}

func NewNormalizedDefinitionUnknownValue() NormalizedDefinition {
	return NormalizedDefinition{
		state: attr.ValueStateUnknown,
	}
}

func NewNormalizedDefinitionValue(definition *qstypes.DashboardVersionDefinition) NormalizedDefinition {
	if definition == nil {
		return NewNormalizedDefinitionNullValue()
	} else {
		return NormalizedDefinition{
			state:      attr.ValueStateKnown,
			definition: *definition,
		}
	}
}

func (d NormalizedDefinition) IsNull() bool {
	return d.state == attr.ValueStateNull
}

func (d NormalizedDefinition) IsUnknown() bool {
	return d.state == attr.ValueStateUnknown
}

func (v NormalizedDefinition) Type(_ context.Context) attr.Type {
	return NormalizedDefinitionType{}
}

func (v NormalizedDefinition) String() string {
	if v.IsUnknown() {
		return attr.UnknownValueString
	} else if v.IsNull() {
		return attr.NullValueString
	} else {
		return fmt.Sprintf("%v", v.definition)
	}
}

func (v NormalizedDefinition) ValueString() string {
	s, err := toNormalizedJson(&v.definition)
	if err != nil {
		return ""
	} else {
		return s
	}
}

func (v NormalizedDefinition) ToStringValue(context.Context) (basetypes.StringValue, diag.Diagnostics) {
	return basetypes.NewStringValue(v.ValueString()), nil
}

func (v NormalizedDefinition) ToTerraformValue(_ context.Context) (tftypes.Value, error) {
	switch v.state {
	case attr.ValueStateKnown:
		s, err := toNormalizedJson(&v.definition)
		if err != nil {
			return tftypes.NewValue(tftypes.String, tftypes.UnknownValue), err
		} else {
			return tftypes.NewValue(tftypes.String, s), nil
		}
	case attr.ValueStateNull:
		return tftypes.NewValue(tftypes.String, nil), nil
	case attr.ValueStateUnknown:
		return tftypes.NewValue(tftypes.String, tftypes.UnknownValue), nil
	default:
		panic(fmt.Sprintf("invalid state: %s", v.state))
	}
}

func (v NormalizedDefinition) Equal(other attr.Value) bool {
	o, ok := other.(NormalizedDefinition)
	if !ok {
		return false
	} else if v.state != o.state {
		return false
	} else if v.state != attr.ValueStateKnown {
		return true
	} else {
		return v.ValueString() == o.ValueString()
	}
}

func (v NormalizedDefinition) StringSemanticEquals(ctx context.Context, o basetypes.StringValuable) (bool, diag.Diagnostics) {
	var diags diag.Diagnostics

	s, diags := o.ToStringValue(ctx)
	if diags != nil && diags.HasError() {
		return false, diags
	}

	definition, err := NewDefinitionFromStringValue(s)
	if err != nil {
		diags.AddError("Semantic Equality Check Error", err.Error())

		return false, diags
	}

	result := v.Equal(NewNormalizedDefinitionValue(definition))

	return result, diags
}

func (v NormalizedDefinition) ToDefinition() *qstypes.DashboardVersionDefinition {
	return &v.definition
}

// func jsonEqual(s1, s2 string) (bool, error) {
// 	s1, err := normalizeJSONString(s1)
// 	if err != nil {
// 		return false, err
// 	}

// 	s2, err = normalizeJSONString(s2)
// 	if err != nil {
// 		return false, err
// 	}

// 	return s1 == s2, nil
// }

// func normalizeJSONString(jsonStr string) (string, error) {
// 	dec := json.NewDecoder(strings.NewReader(jsonStr))

// 	// This ensures the JSON decoder will not parse JSON numbers into Go's float64 type; avoiding Go
// 	// normalizing the JSON number representation or imposing limits on numeric range. See the unit test cases
// 	// of StringSemanticEquals for examples.
// 	dec.UseNumber()

// 	var temp interface{}
// 	if err := dec.Decode(&temp); err != nil {
// 		return "", err
// 	}

// 	jsonBytes, err := json.Marshal(&temp)
// 	if err != nil {
// 		return "", err
// 	}

// 	return string(jsonBytes), nil
// }

// Unmarshal calls (encoding/json).Unmarshal with the Normalized StringValue and `target` input. A null or unknown value will produce an error diagnostic.
// See encoding/json docs for more on usage: https://pkg.go.dev/encoding/json#Unmarshal
// func (v NormalizedDefinition) Unmarshal(target any) diag.Diagnostics {
// 	var diags diag.Diagnostics

// 	if v.IsNull() {
// 		diags.Append(diag.NewErrorDiagnostic("Normalized JSON Unmarshal Error", "json string value is null"))
// 		return diags
// 	}

// 	if v.IsUnknown() {
// 		diags.Append(diag.NewErrorDiagnostic("Normalized JSON Unmarshal Error", "json string value is unknown"))
// 		return diags
// 	}

// 	err := json.Unmarshal([]byte(v.ValueString()), target)
// 	if err != nil {
// 		diags.Append(diag.NewErrorDiagnostic("Normalized JSON Unmarshal Error", err.Error()))
// 	}

// 	return diags
// }

// func NewNormalizedDefinitionNullValue() NormalizedDefinition {
// 	return NormalizedDefinition{
// 		StringValue: basetypes.NewStringNull(),
// 	}
// }

// func NewNormalizedDefinitionValue(definition *qstypes.DashboardVersionDefinition) NormalizedDefinition {
// 	if jsonString, err := toNormalizedJson(definition); err != nil {
// 		return NewNormalizedDefinitionNullValue()
// 	} else {
// 		return NormalizedDefinition{
// 			StringValue: basetypes.NewStringValue(jsonString),
// 		}
// 	}
// }

func NewDefinitionFromStringValue(in basetypes.StringValue) (*qstypes.DashboardVersionDefinition, error) {
	var target qstypes.DashboardVersionDefinition

	err := json.Unmarshal([]byte(in.ValueString()), &target)
	if err != nil {
		return nil, err
	}

	return &target, nil
}

func toNormalizedJson(definition *qstypes.DashboardVersionDefinition) (string, error) {
	var jsonBytes []byte
	var err error

	jsonBytes, err = json.Marshal(definition)
	if err != nil {
		return "", err
	}

	dec := json.NewDecoder(strings.NewReader(string(jsonBytes)))
	dec.UseNumber()

	var temp interface{}
	if err := dec.Decode(&temp); err != nil {
		return "", err
	}

	jsonBytes, err = json.Marshal(&temp)
	if err != nil {
		return "", err
	}

	return string(jsonBytes), nil
}
