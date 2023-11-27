package provider

import (
	"testing"

	"github.com/hashicorp/terraform-plugin-testing/helper/resource"
)

func TestAccQuicksightDashboardDataSource(t *testing.T) {
	resource.Test(t, resource.TestCase{
		ProtoV6ProviderFactories: testAccProtoV6ProviderFactories,
		Steps: []resource.TestStep{
			{
				Config: providerConfig + `
					data "specifai_quicksight_dashboard" "test" {
						dashboard_id = "a775daeb-5263-4fb2-9f29-815c066bae76"
					}
				`,
				Check: resource.ComposeAggregateTestCheckFunc(
					resource.TestCheckResourceAttr("data.specifai_quicksight_dashboard.test", "dashboard_id", "a775daeb-5263-4fb2-9f29-815c066bae76"),
					resource.TestCheckResourceAttr("data.specifai_quicksight_dashboard.test", "aws_account_id", "296896140035"),
					resource.TestCheckResourceAttrSet("data.specifai_quicksight_dashboard.test", "created_time"),
					resource.TestCheckResourceAttrSet("data.specifai_quicksight_dashboard.test", "last_updated_time"),
					resource.TestCheckResourceAttrSet("data.specifai_quicksight_dashboard.test", "last_published_time"),
					resource.TestCheckResourceAttrSet("data.specifai_quicksight_dashboard.test", "name"),
					resource.TestCheckResourceAttrSet("data.specifai_quicksight_dashboard.test", "status"),
					resource.TestCheckResourceAttrSet("data.specifai_quicksight_dashboard.test", "version_number"),
				),
			},
		},
	})
}
