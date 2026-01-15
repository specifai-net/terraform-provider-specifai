package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
)

func TestQuicksightTopicResource_Schema(t *testing.T) {
	res := NewQuicksightTopicResource()

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
		"topic_id":    {required: true, computed: false},
		"name":        {required: true, computed: false},
		"data_sets":   {required: true, computed: false},
		"arn":         {required: false, computed: true},
		"aws_account_id": {required: false, computed: true},
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

func TestQuicksightTopicPermissionResource_Schema(t *testing.T) {
	res := NewQuicksightTopicPermissionResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"topic_id", "principal", "actions"}
	for _, attr := range requiredAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
		}
	}

	// Check actions is a list attribute
	if actionsAttr, exists := resp.Schema.Attributes["actions"]; exists {
		if _, ok := actionsAttr.(schema.ListAttribute); !ok {
			t.Error("actions attribute should be a ListAttribute")
		}
	}
}

func TestQuicksightTopicRefreshScheduleResource_Schema(t *testing.T) {
	res := NewQuicksightTopicRefreshScheduleResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"topic_id", "dataset_id", "based_on_spice_schedule", "is_enabled"}
	for _, attr := range requiredAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
		}
	}

	// Check boolean attributes are correct type
	boolAttrs := []string{"based_on_spice_schedule", "is_enabled"}
	for _, attrName := range boolAttrs {
		if attr, exists := resp.Schema.Attributes[attrName]; exists {
			if _, ok := attr.(schema.BoolAttribute); !ok {
				t.Errorf("%s attribute should be a BoolAttribute", attrName)
			}
		}
	}
}

func TestQuicksightTopicResource_Metadata(t *testing.T) {
	res := NewQuicksightTopicResource()

	req := resource.MetadataRequest{
		ProviderTypeName: "specifai",
	}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_topic"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}