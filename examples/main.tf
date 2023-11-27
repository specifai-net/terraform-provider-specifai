terraform {
  required_providers {
    specifai = {
      source = "specifai.eu/terraform/specifai"
    }
  }
}

provider "specifai" {
  region = "eu-west-1"
}

data "specifai_quicksight_dashboard" "test" {
  dashboard_id = "a775daeb-5263-4fb2-9f29-815c066bae76"
}

output "dashboard" {
  value = data.specifai_quicksight_dashboard.test
}