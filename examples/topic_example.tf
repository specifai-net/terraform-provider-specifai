terraform {
  required_providers {
    specifai = {
      source = "specifai-net/specifai"
    }
  }
}

provider "specifai" {
  region = "eu-west-1"
}

resource "specifai_quicksight_topic" "sales" {
  topic_id    = "sales-topic"
  name        = "Sales Topic"
  description = "Sales data topic for Q&A"

  data_sets = jsonencode([
    {
      "DatasetArn": "arn:aws:quicksight:eu-west-1:123456789012:dataset/300242f6-24aa-4fcb-bad6-61f5fa77ae4c",
      "DatasetName": "Sales Dataset",
      "DatasetDescription": "Sales data"
    }
  ])

  custom_instructions = "Focus on sales metrics and trends"
  user_experience_version = "NEW_READER_EXPERIENCE"
}

resource "specifai_quicksight_topic_permission" "owner_permission" {
  topic_id  = specifai_quicksight_topic.sales.topic_id
  principal = "arn:aws:quicksight:eu-west-1:123456789012:user/default/owner"
  actions   = [
    "quicksight:DescribeTopicRefresh",
    "quicksight:ListTopicRefreshSchedules",
    "quicksight:DescribeTopicRefreshSchedule",
    "quicksight:DeleteTopic",
    "quicksight:UpdateTopic",
    "quicksight:CreateTopicRefreshSchedule",
    "quicksight:DeleteTopicRefreshSchedule",
    "quicksight:UpdateTopicRefreshSchedule",
    "quicksight:DescribeTopic",
    "quicksight:DescribeTopicPermissions",
    "quicksight:UpdateTopicPermissions"
  ]
}

resource "specifai_quicksight_topic_refresh_schedule" "sales_refresh" {
  topic_id                = specifai_quicksight_topic.sales.topic_id
  dataset_id              = "300242f6-24aa-4fcb-bad6-61f5fa77ae4c"
  dataset_name            = "Sales Dataset"
  based_on_spice_schedule = true
  is_enabled              = true
}