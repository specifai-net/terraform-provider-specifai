# specifai_quicksight_topic_refresh_schedule

Manages a refresh schedule for a QuickSight Topic.

## Example Usage

```terraform
resource "specifai_quicksight_topic_refresh_schedule" "example" {
  topic_id              = "example-topic"
  dataset_id            = "example-dataset"
  based_on_spice_schedule = false
  is_enabled            = true
  starting_at           = "2024-01-01T00:00:00Z"
  timezone              = "UTC"
  repeat_at             = "0 2 * * *"
  topic_schedule_type   = "DAILY"
}
```

## Argument Reference

The following arguments are supported:

* `topic_id` - (Required) Identifier for the topic.
* `dataset_id` - (Required) The ID of the dataset.
* `based_on_spice_schedule` - (Required) Whether to schedule runs at the same schedule that is specified in SPICE dataset.
* `is_enabled` - (Required) Whether the schedule is enabled.
* `topic_schedule_type` - (Required) The type of refresh schedule. Valid values are `HOURLY`, `DAILY`, `WEEKLY`, and `MONTHLY`.
* `dataset_name` - (Optional) The name of the dataset.
* `starting_at` - (Optional) The starting date and time for the refresh schedule (RFC3339 format).
* `timezone` - (Optional) The timezone for the refresh schedule.
* `repeat_at` - (Optional) The time of day when the refresh should run.
* `aws_account_id` - (Optional) AWS account ID. If not specified, the default account ID is used.

## Import

QuickSight Topic Refresh Schedules can be imported using the `aws_account_id/topic_id/dataset_id`, e.g.,

```
$ terraform import specifai_quicksight_topic_refresh_schedule.example 123456789012/example-topic/example-dataset
```