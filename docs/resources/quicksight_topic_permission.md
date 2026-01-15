# specifai_quicksight_topic_permission

Manages permissions for a QuickSight Topic.

## Example Usage

```terraform
resource "specifai_quicksight_topic" "example" {
  topic_id = "example-topic"
  name     = "Example Topic"
  data_sets = jsonencode([{
    DatasetArn = "arn:aws:quicksight:us-east-1:123456789012:dataset/example"
  }])
}

resource "specifai_quicksight_topic_permission" "example" {
  topic_id  = specifai_quicksight_topic.example.topic_id
  principal = "arn:aws:quicksight:us-east-1:123456789012:user/default/example-user"
  actions   = [
    "quicksight:DescribeTopic",
    "quicksight:UpdateTopic",
    "quicksight:DeleteTopic",
    "quicksight:DescribeTopicPermissions",
    "quicksight:UpdateTopicPermissions"
  ]
}
```

## Argument Reference

The following arguments are supported:

* `topic_id` - (Required) Identifier for the topic. Use a reference to the topic resource (e.g., `specifai_quicksight_topic.example.topic_id`) to ensure proper dependency ordering.
* `principal` - (Required) The Amazon Resource Name (ARN) of the principal (user or group).
* `actions` - (Required) List of IAM actions to grant permissions for. Common actions include:
  - `quicksight:DescribeTopic`
  - `quicksight:UpdateTopic`
  - `quicksight:DeleteTopic`
  - `quicksight:DescribeTopicPermissions`
  - `quicksight:UpdateTopicPermissions`
  - `quicksight:DescribeTopicRefresh`
  - `quicksight:CreateTopicRefreshSchedule`
  - `quicksight:UpdateTopicRefreshSchedule`
  - `quicksight:DeleteTopicRefreshSchedule`
* `aws_account_id` - (Optional) AWS account ID. If not specified, the default account ID from the provider configuration is used.

## Attribute Reference

In addition to all arguments above, the following attributes are exported:

* `aws_account_id` - The AWS account ID used (computed if not explicitly set).

## Import

Import is not currently supported for QuickSight Topic Permissions.