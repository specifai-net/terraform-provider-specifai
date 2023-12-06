package provider

import (
	"context"
	"fmt"

	"github.com/hashicorp/terraform-plugin-framework/attr"
	"github.com/hashicorp/terraform-plugin-framework/attr/xattr"
	"github.com/hashicorp/terraform-plugin-framework/diag"
	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/types/basetypes"
	"github.com/hashicorp/terraform-plugin-go/tftypes"
)

var (
	_ basetypes.StringTypable = (*NormalizedDefinitionType)(nil)
	_ xattr.TypeWithValidate  = (*NormalizedDefinitionType)(nil)
)

type NormalizedDefinitionType struct{}

func (t NormalizedDefinitionType) ApplyTerraform5AttributePathStep(step tftypes.AttributePathStep) (interface{}, error) {
	return nil, fmt.Errorf("cannot apply AttributePathStep %T to %s", step, t.String())
}

func (t NormalizedDefinitionType) Equal(o attr.Type) bool {
	_, ok := o.(NormalizedDefinitionType)
	return ok
}

func (t NormalizedDefinitionType) String() string {
	return "specifai.NormalizedDefinitionType"
}

func (t NormalizedDefinitionType) TerraformType(_ context.Context) tftypes.Type {
	return tftypes.String
}

func (t NormalizedDefinitionType) ValueFromString(_ context.Context, v basetypes.StringValue) (basetypes.StringValuable, diag.Diagnostics) {
	var diags diag.Diagnostics

	definition, err := NewDefinitionFromStringValue(v)
	if err != nil {
		diags.AddError("Semantic Equality Check Error", err.Error())
		return basetypes.NewStringNull(), diags
	}

	return NewNormalizedDefinitionValue(definition), diags
}

func (t NormalizedDefinitionType) ValueFromTerraform(ctx context.Context, in tftypes.Value) (attr.Value, error) {
	if !in.IsKnown() {
		return NewNormalizedDefinitionUnknownValue(), nil
	} else if in.IsNull() {
		return NewNormalizedDefinitionNullValue(), nil
	} else {
		var s string
		err := in.As(&s)
		if err != nil {
			return nil, err
		}

		definition, err := NewDefinitionFromStringValue(basetypes.NewStringValue(s))
		if err != nil {
			return nil, err
		}

		return NewNormalizedDefinitionValue(definition), nil
	}
}

func (t NormalizedDefinitionType) ValueType(_ context.Context) attr.Value {
	// This Value does not need to be valid.
	return NormalizedDefinition{}
}

// String returns a human readable string of the type name.
// func (t NormalizedDefinitionType) String() string {
// 	return "specifai.NormalizedDefinitionType"
// }

// // ValueType returns the Value type.
// func (t NormalizedDefinitionType) ValueType(ctx context.Context) attr.Value {
// 	return NormalizedDefinition{}
// }

// // Equal returns true if the given type is equivalent.
// func (t NormalizedDefinitionType) Equal(o attr.Type) bool {
// 	other, ok := o.(NormalizedDefinitionType)
// 	if !ok {
// 		return false
// 	}
// 	return t.StringType.Equal(other.StringType)
// }

// Validate implements type validation. This type requires the value provided to be a String value that is valid JSON format (RFC 7159).
func (t NormalizedDefinitionType) Validate(ctx context.Context, in tftypes.Value, path path.Path) diag.Diagnostics {
	var diags diag.Diagnostics

	if in.Type() == nil {
		return diags
	}

	if !in.Type().Is(tftypes.String) {
		diags.AddAttributeError(
			path,
			"Normalized Definition Type Validation Error",
			fmt.Sprintf("expected String value, received %T with value: %v", in, in),
		)
		return diags
	}

	if !in.IsKnown() || in.IsNull() {
		return diags
	}

	var s string
	if err := in.As(&s); err != nil {
		diags.AddAttributeError(
			path,
			"Normalized Definition Type Validation Error",
			err.Error(),
		)
		return diags
	}

	_, err := NewDefinitionFromStringValue(basetypes.NewStringValue(s))
	if err != nil {
		diags.AddAttributeError(
			path,
			"Normalized Definition Type Validation Error",
			err.Error(),
		)
	}

	return diags
}

// // ValueFromString returns a StringValuable type given a StringValue.
// func (t NormalizedDefinitionType) ValueFromString(ctx context.Context, in basetypes.StringValue) (basetypes.StringValuable, diag.Diagnostics) {
// 	var diags diag.Diagnostics

// 	tflog.Debug(ctx, fmt.Sprintf(">>>>>>>>>>>>>>>> ValueFromString %s", in.String()))

// 	if in.IsNull() || in.IsUnknown() {
// 		return NewNormalizedDefinitionNullValue(), diags
// 	}

// 	definition, err := NewDefinitionFromStringValue(in)
// 	if err != nil {
// 		diags.Append(diag.NewErrorDiagnostic("Unmarshal Error", err.Error()))
// 		return nil, diags
// 	}

// 	return NewNormalizedDefinitionValue(definition), nil
// }

// // ValueFromTerraform returns a Value given a tftypes.Value.  This is meant to convert the tftypes.Value into a more convenient Go type
// // for the provider to consume the data with.
// func (t NormalizedDefinitionType) ValueFromTerraform(ctx context.Context, in tftypes.Value) (attr.Value, error) {

// 	attrValue, err := t.StringType.ValueFromTerraform(ctx, in)
// 	if err != nil {
// 		return nil, err
// 	}

// 	stringValue, ok := attrValue.(basetypes.StringValue)
// 	if !ok {
// 		return nil, fmt.Errorf("unexpected value type of %T", attrValue)
// 	}

// 	tflog.Debug(ctx, fmt.Sprintf(">>>>>>>>>>>>>>>> ValueFromTerraform %s", stringValue.String()))

// 	stringValuable, diags := t.ValueFromString(ctx, stringValue)
// 	if diags.HasError() {
// 		return nil, fmt.Errorf("unexpected error converting StringValue to StringValuable: %v", diags)
// 	}

// 	return stringValuable, nil
// }
