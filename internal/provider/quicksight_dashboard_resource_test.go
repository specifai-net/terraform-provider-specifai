package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
)

func TestQuicksightDashboardResource_Schema(t *testing.T) {
	res := NewQuicksightDashboardResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	// Check required attributes exist and are configured correctly
	requiredTests := map[string]struct {
		required bool
		computed bool
	}{
		"dashboard_id":        {required: true, computed: false},
		"name":                {required: true, computed: false},
		"definition":          {required: true, computed: false},
		"version_description": {required: true, computed: false},
		"arn":                 {required: false, computed: true},
		"aws_account_id":      {required: false, computed: true},
		"created_time":        {required: false, computed: true},
		"last_updated_time":   {required: false, computed: true},
		"last_published_time": {required: false, computed: true},
		"status":              {required: false, computed: true},
		"version_number":      {required: false, computed: true},
	}

	for attrName, expected := range requiredTests {
		attr, exists := resp.Schema.Attributes[attrName]
		if !exists {
			t.Errorf("Attribute %s missing from schema", attrName)
			continue
		}

		if stringAttr, ok := attr.(schema.StringAttribute); ok {
			if stringAttr.IsRequired() != expected.required {
				t.Errorf("Attribute %s required=%v, expected=%v", attrName, stringAttr.IsRequired(), expected.required)
			}
			if stringAttr.IsComputed() != expected.computed {
				t.Errorf("Attribute %s computed=%v, expected=%v", attrName, stringAttr.IsComputed(), expected.computed)
			}
		} else if int64Attr, ok := attr.(schema.Int64Attribute); ok {
			if int64Attr.IsRequired() != expected.required {
				t.Errorf("Attribute %s required=%v, expected=%v", attrName, int64Attr.IsRequired(), expected.required)
			}
			if int64Attr.IsComputed() != expected.computed {
				t.Errorf("Attribute %s computed=%v, expected=%v", attrName, int64Attr.IsComputed(), expected.computed)
			}
		}
	}
}

func TestQuicksightDashboardResource_Metadata(t *testing.T) {
	res := NewQuicksightDashboardResource()

	req := resource.MetadataRequest{
		ProviderTypeName: "specifai",
	}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_dashboard"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}