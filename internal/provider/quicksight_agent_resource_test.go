package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	rschema "github.com/hashicorp/terraform-plugin-framework/resource/schema"
)

func TestQuicksightAgentResource_Schema(t *testing.T) {
	res := NewQuicksightAgentResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"agent_id", "name"}
	for _, attr := range requiredAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
		}
	}

	// Verify computed attributes
	computedAttrs := []string{"arn", "aws_account_id"}
	for _, attr := range computedAttrs {
		a, exists := resp.Schema.Attributes[attr]
		if !exists {
			t.Errorf("Computed attribute %s missing from schema", attr)
			continue
		}
		if stringAttr, ok := a.(rschema.StringAttribute); ok {
			if !stringAttr.IsComputed() {
				t.Errorf("Attribute %s should be computed", attr)
			}
		}
	}

	// Verify list attributes
	listAttrs := []string{"starter_prompts", "spaces", "action_connectors"}
	for _, attr := range listAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("List attribute %s missing from schema", attr)
		}
	}
}

func TestQuicksightAgentResource_Metadata(t *testing.T) {
	res := NewQuicksightAgentResource()

	req := resource.MetadataRequest{ProviderTypeName: "specifai"}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_agent"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}

func TestQuicksightAgentPermissionResource_Schema(t *testing.T) {
	res := NewQuicksightAgentPermissionResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"agent_id", "principal", "actions"}
	for _, attr := range requiredAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
		}
	}
}

func TestQuicksightAgentPermissionResource_Metadata(t *testing.T) {
	res := NewQuicksightAgentPermissionResource()

	req := resource.MetadataRequest{ProviderTypeName: "specifai"}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_agent_permission"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}

func TestQuicksightAgentDataSource_Schema(t *testing.T) {
	ds := NewQuicksightAgentDataSource()

	req := datasource.SchemaRequest{}
	resp := &datasource.SchemaResponse{}

	ds.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	// Required input
	if _, exists := resp.Schema.Attributes["agent_id"]; !exists {
		t.Error("Required attribute agent_id missing from schema")
	}

	// Computed outputs
	computedAttrs := []string{"name", "arn", "agent_lifecycle", "agent_status", "description"}
	for _, attr := range computedAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Computed attribute %s missing from schema", attr)
		}
	}
}

func TestQuicksightAgentDataSource_Metadata(t *testing.T) {
	ds := NewQuicksightAgentDataSource()

	req := datasource.MetadataRequest{ProviderTypeName: "specifai"}
	resp := &datasource.MetadataResponse{}

	ds.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_agent"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}
