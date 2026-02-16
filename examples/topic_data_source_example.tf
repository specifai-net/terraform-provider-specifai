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

# Read an existing QuickSight topic
data "specifai_quicksight_topic" "example" {
  topic_id = "my-existing-topic-id"
}

# Output the topic information
output "topic_name" {
  value = data.specifai_quicksight_topic.example.name
}

output "topic_arn" {
  value = data.specifai_quicksight_topic.example.arn
}

output "topic_datasets" {
  value = data.specifai_quicksight_topic.example.data_sets
}