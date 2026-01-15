# specifai_quicksight_topic_permission

Manages permissions for a QuickSight Topic.

## Example Usage

```terraform
resource "specifai_quicksight_topic_permission" "example" {
  topic_id  = "example-topic"
  principal = "arn:aws:quicksight:us-east-1:123456789012:user/default/example-user"
  actions   = [
    "quicksight:DescribeTopic",
    "quicksight:ListTopics"
  ]
}
```

## Argument Reference

The following arguments are supported:

* `topic_id` - (Required) Identifier for the topic.
* `principal` - (Required) The Amazon Resource Name (ARN) of the principal.
* `actions` - (Required) List of IAM actions to grant or revoke permissions on.
* `aws_account_id` - (Optional) AWS account ID. If not specified, the default account ID is used.

## Import

QuickSight Topic Permissions can be imported using the `aws_account_id/topic_id/principal`, e.g.,

```
$ terraform import specifai_quicksight_topic_permission.example 123456789012/example-topic/arn:aws:quicksight:us-east-1:123456789012:user/default/example-user
```