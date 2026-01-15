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
      DatasetArn = "arn:aws:quicksight:us-east-1:123456789012:dataset/sales-dataset"
      DatasetName = "Sales Data"
      DatasetDescription = "Monthly sales data"
    },
    {
      DatasetArn = "arn:aws:quicksight:us-east-1:123456789012:dataset/customer-dataset"
      DatasetName = "Customer Data"
      DatasetDescription = "Customer information"
      Columns = [
        {
          ColumnName = "customer_id"
          ColumnDescription = "Unique customer identifier"
          ColumnDataRole = "DIMENSION"
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
* `data_sets` - (Required) JSON string containing an array of dataset objects. Each dataset must contain at least `DatasetArn`. Additional fields like `DatasetName`, `DatasetDescription`, `Columns`, `CalculatedFields`, `Filters`, etc. can be included as per AWS QuickSight DatasetMetadata structure. Note: Field names must use PascalCase (e.g., `DatasetArn`, not `dataset_arn`).
* `description` - (Optional) The description of the topic.
* `custom_instructions` - (Optional) Custom instructions for the topic.
* `user_experience_version` - (Optional) The user experience version of the topic. Valid values are `LEGACY` and `NEW_READER_EXPERIENCE`.
* `aws_account_id` - (Optional) AWS account ID. If not specified, the default account ID from the provider configuration is used.

## Attribute Reference

In addition to all arguments above, the following attributes are exported:

* `arn` - ARN of the topic.
* `aws_account_id` - The AWS account ID used (computed if not explicitly set).

## Import

Import is not currently supported for QuickSight Topics.