package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	rschema "github.com/hashicorp/terraform-plugin-framework/resource/schema"
)

func TestQuicksightSpaceResource_Schema(t *testing.T) {
	res := NewQuicksightSpaceResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"space_id", "name"}
	for _, attr := range requiredAttrs {
		a, exists := resp.Schema.Attributes[attr]
		if !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
			continue
		}
		if !a.IsRequired() {
			t.Errorf("Attribute %s should be required", attr)
		}
	}

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
}

func TestQuicksightSpaceResource_Metadata(t *testing.T) {
	res := NewQuicksightSpaceResource()

	req := resource.MetadataRequest{ProviderTypeName: "specifai"}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_space"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}

func TestQuicksightSpacePermissionResource_Schema(t *testing.T) {
	res := NewQuicksightSpacePermissionResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	requiredAttrs := []string{"space_id", "principal", "actions"}
	for _, attr := range requiredAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Required attribute %s missing from schema", attr)
		}
	}
}

func TestQuicksightSpacePermissionResource_Metadata(t *testing.T) {
	res := NewQuicksightSpacePermissionResource()

	req := resource.MetadataRequest{ProviderTypeName: "specifai"}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_space_permission"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}

func TestQuicksightSpaceDataSource_Schema(t *testing.T) {
	ds := NewQuicksightSpaceDataSource()

	req := datasource.SchemaRequest{}
	resp := &datasource.SchemaResponse{}

	ds.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	if _, exists := resp.Schema.Attributes["space_id"]; !exists {
		t.Error("Required attribute space_id missing from schema")
	}

	computedAttrs := []string{"name", "description", "arn"}
	for _, attr := range computedAttrs {
		if _, exists := resp.Schema.Attributes[attr]; !exists {
			t.Errorf("Computed attribute %s missing from schema", attr)
		}
	}
}

func TestQuicksightSpaceDataSource_Metadata(t *testing.T) {
	ds := NewQuicksightSpaceDataSource()

	req := datasource.MetadataRequest{ProviderTypeName: "specifai"}
	resp := &datasource.MetadataResponse{}

	ds.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_space"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}
