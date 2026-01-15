# specifai_quicksight_topic_refresh_schedule

Manages a refresh schedule for a QuickSight Topic.

## Example Usage

```terraform
resource "specifai_quicksight_topic" "example" {
  topic_id = "example-topic"
  name     = "Example Topic"
  data_sets = jsonencode([{
    DatasetArn = "arn:aws:quicksight:us-east-1:123456789012:dataset/example-dataset"
  }])
}

resource "specifai_quicksight_topic_refresh_schedule" "example" {
  topic_id                = specifai_quicksight_topic.example.topic_id
  dataset_id              = "example-dataset"
  dataset_name            = "Example Dataset"
  based_on_spice_schedule = true
  is_enabled              = true
}
```

## Argument Reference

The following arguments are supported:

* `topic_id` - (Required) Identifier for the topic. Use a reference to the topic resource (e.g., `specifai_quicksight_topic.example.topic_id`) to ensure proper dependency ordering.
* `dataset_id` - (Required) The ID of the dataset (not the full ARN, just the ID portion).
* `based_on_spice_schedule` - (Required) Whether to schedule runs at the same schedule that is specified in the SPICE dataset.
* `is_enabled` - (Required) Whether the refresh schedule is enabled.
* `dataset_name` - (Optional) The name of the dataset.
* `starting_at` - (Optional) The starting date and time for the refresh schedule in RFC3339 format (e.g., `2024-01-01T09:00:00Z`).
* `timezone` - (Optional) The timezone for the refresh schedule (e.g., `UTC`, `America/New_York`).
* `repeat_at` - (Optional) The frequency of the refresh. Common values include `DAILY`, `WEEKLY`, `MONTHLY`.
* `topic_schedule_type` - (Optional) The type of refresh schedule. Valid values are `HOURLY`, `DAILY`, `WEEKLY`, and `MONTHLY`.
* `aws_account_id` - (Optional) AWS account ID. If not specified, the default account ID from the provider configuration is used.

## Attribute Reference

In addition to all arguments above, the following attributes are exported:

* `aws_account_id` - The AWS account ID used (computed if not explicitly set).

## Import

Import is not currently supported for QuickSight Topic Refresh Schedules.