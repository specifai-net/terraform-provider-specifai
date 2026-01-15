# specifai_quicksight_topic

Manages a QuickSight Topic.

## Example Usage

```terraform
resource "specifai_quicksight_topic" "example" {
  topic_id    = "example-topic"
  name        = "Example Sales Topic"
  description = "A topic for sales data analysis"
  custom_instructions = "Focus on sales metrics and trends"
  user_experience_version = "NEW_READER_EXPERIENCE"
  data_sets   = jsonencode([
    {
      dataset_arn = "arn:aws:quicksight:us-east-1:123456789012:dataset/sales-dataset"
      dataset_name = "Sales Data"
      dataset_description = "Monthly sales data"
    },
    {
      dataset_arn = "arn:aws:quicksight:us-east-1:123456789012:dataset/customer-dataset"
      dataset_name = "Customer Data"
      dataset_description = "Customer information"
      columns = [
        {
          column_name = "customer_id"
          column_description = "Unique customer identifier"
          column_data_role = "DIMENSION"
        }
      ]
    }
  ])
}
```

## Argument Reference

The following arguments are supported:

* `topic_id` - (Required) Identifier for the topic.
* `name` - (Required) The name of the topic.
* `description` - (Optional) The description of the topic.
* `custom_instructions` - (Optional) Custom instructions for the topic.
* `user_experience_version` - (Optional) The user experience version of the topic. Valid values are `LEGACY` and `NEW_READER_EXPERIENCE`.
* `data_sets` - (Required) JSON string containing an array of dataset objects. Each dataset must contain at least `dataset_arn`. Additional fields like `dataset_name`, `dataset_description`, `columns`, `calculated_fields`, `filters`, etc. can be included as per AWS QuickSight DatasetMetadata structure.
* `aws_account_id` - (Optional) AWS account ID. If not specified, the default account ID is used.

## Attribute Reference

In addition to all arguments above, the following attributes are exported:

* `arn` - ARN of the topic.

## Import

QuickSight Topics can be imported using the `aws_account_id/topic_id`, e.g.,

```
$ terraform import specifai_quicksight_topic.example 123456789012/example-topic
```