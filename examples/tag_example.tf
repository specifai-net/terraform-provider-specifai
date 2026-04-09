terraform {
  required_providers {
    specifai = {
      source = "specifai-net/specifai"
    }
  }
}

provider "specifai" {
  region = "us-east-1"
}

resource "specifai_quicksight_tag" "user_tags" {
  resource_arn = "arn:aws:quicksight:us-east-1:123456789012:user/default/example-user"
  tags = {
    Department  = "Sales"
    Environment = "Production"
  }
}

resource "specifai_quicksight_tag" "dashboard_tags" {
  resource_arn = "arn:aws:quicksight:us-east-1:123456789012:dashboard/example-dashboard"
  tags = {
    Team       = "Analytics"
    CostCenter = "12345"
  }
}
