package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
)

func TestQuicksightDashboardPermissionResource_Schema(t *testing.T) {
	res := NewQuicksightDashboardPermissionResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"dashboard_id", "principal", "actions"}
	for _, attr := range requiredAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
		}
	}

	// Check actions is a set attribute
	if actionsAttr, exists := resp.Schema.Attributes["actions"]; exists {
		if _, ok := actionsAttr.(schema.SetAttribute); !ok {
			t.Error("actions attribute should be a SetAttribute")
		}
	}

	// Check aws_account_id is optional and computed
	if accountAttr, exists := resp.Schema.Attributes["aws_account_id"]; exists {
		if stringAttr, ok := accountAttr.(schema.StringAttribute); ok {
			if stringAttr.IsRequired() {
				t.Error("aws_account_id should not be required")
			}
			if !stringAttr.IsComputed() {
				t.Error("aws_account_id should be computed")
			}
		}
	}
}

func TestQuicksightDashboardPermissionResource_Metadata(t *testing.T) {
	res := NewQuicksightDashboardPermissionResource()

	req := resource.MetadataRequest{
		ProviderTypeName: "specifai",
	}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_dashboard_permission"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}