package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
)

func TestNormalizedDashboardDefinitionDataSource_Schema(t *testing.T) {
	ds := NewnormalizedDashboardDefinitionDataSource()

	req := datasource.SchemaRequest{}
	resp := &datasource.SchemaResponse{}

	ds.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	// Check required attributes exist and are configured correctly
	requiredTests := map[string]struct {
		required bool
		computed bool
	}{
		"definition":            {required: true, computed: false},
		"normalized_definition": {required: false, computed: true},
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
		}
	}
}

func TestNormalizedDashboardDefinitionDataSource_Metadata(t *testing.T) {
	ds := NewnormalizedDashboardDefinitionDataSource()

	req := datasource.MetadataRequest{
		ProviderTypeName: "specifai",
	}
	resp := &datasource.MetadataResponse{}

	ds.Metadata(context.Background(), req, resp)

	expected := "specifai_normalized_dashboard_definition"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}
