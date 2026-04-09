package provider

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

func TestQuicksightTagResource_Schema(t *testing.T) {
	res := NewQuicksightTagResource()

	req := resource.SchemaRequest{}
	resp := &resource.SchemaResponse{}

	res.Schema(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Schema validation failed: %v", resp.Diagnostics.Errors())
	}

	// Check required attributes exist
	requiredAttrs := []string{"resource_arn", "tags"}
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

	// Check resource_arn is a string attribute
	if _, ok := resp.Schema.Attributes["resource_arn"].(schema.StringAttribute); !ok {
		t.Error("resource_arn should be a StringAttribute")
	}

	// Check tags is a map attribute
	if mapAttr, ok := resp.Schema.Attributes["tags"].(schema.MapAttribute); !ok {
		t.Error("tags should be a MapAttribute")
	} else if mapAttr.ElementType != types.StringType {
		t.Error("tags element type should be StringType")
	}
}

func TestQuicksightTagResource_Metadata(t *testing.T) {
	res := NewQuicksightTagResource()

	req := resource.MetadataRequest{
		ProviderTypeName: "specifai",
	}
	resp := &resource.MetadataResponse{}

	res.Metadata(context.Background(), req, resp)

	expected := "specifai_quicksight_tag"
	if resp.TypeName != expected {
		t.Errorf("TypeName = %s, expected %s", resp.TypeName, expected)
	}
}

func TestQuicksightTagResource_Configure_Nil(t *testing.T) {
	res, ok := NewQuicksightTagResource().(*quicksightTagResource)
	if !ok {
		t.Fatal("Expected *quicksightTagResource")
	}

	req := resource.ConfigureRequest{ProviderData: nil}
	resp := &resource.ConfigureResponse{}

	res.Configure(context.Background(), req, resp)

	if resp.Diagnostics.HasError() {
		t.Errorf("Configure with nil data should not error: %v", resp.Diagnostics.Errors())
	}
}

func TestQuicksightTagResource_Configure_WrongType(t *testing.T) {
	res, ok := NewQuicksightTagResource().(*quicksightTagResource)
	if !ok {
		t.Fatal("Expected *quicksightTagResource")
	}

	req := resource.ConfigureRequest{ProviderData: "wrong type"}
	resp := &resource.ConfigureResponse{}

	res.Configure(context.Background(), req, resp)

	if !resp.Diagnostics.HasError() {
		t.Error("Configure with wrong type should error")
	}
}
