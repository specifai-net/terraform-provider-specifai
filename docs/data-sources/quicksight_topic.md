# specifai_quicksight_topic Data Source

Provides information about a QuickSight topic.

## Example Usage

```terraform
data "specifai_quicksight_topic" "example" {
  topic_id = "my-topic-id"
}
```

## Argument Reference

The following arguments are supported:

* `topic_id` - (Required) The ID of the topic.
* `aws_account_id` - (Optional) The AWS account ID. If not specified, the provider's account ID is used.

## Attribute Reference

In addition to all arguments above, the following attributes are exported:

* `arn` - The Amazon Resource Name (ARN) of the topic.
* `name` - The name of the topic.
* `description` - The description of the topic.
* `data_sets` - JSON string containing the datasets associated with the topic.
* `custom_instructions` - Custom instructions for the topic.
* `user_experience_version` - The user experience version of the topic.