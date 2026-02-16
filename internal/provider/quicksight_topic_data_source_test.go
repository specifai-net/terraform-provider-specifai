package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/datasource/schema"
)

func TestQuicksightTopicDataSource_Schema(t *testing.T) {
	ds := NewQuicksightTopicDataSource()

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
		"topic_id":                {required: true, computed: false},
		"aws_account_id":          {required: false, computed: true},
		"name":                    {required: false, computed: true},
		"description":             {required: false, computed: true},
		"data_sets":               {required: false, computed: true},
		"custom_instructions":     {required: false, computed: true},
		"user_experience_version": {required: false, computed: true},
		"arn":                     {required: false, computed: true},
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

func TestQuicksightTopicDataSource_Metadata(t *testing.T) {
	ds := NewQuicksightTopicDataSource()

	req := datasource.MetadataRequest{
		ProviderTypeName: "specifai",
	}
	resp := &datasource.MetadataResponse{}

	ds.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_topic"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}
