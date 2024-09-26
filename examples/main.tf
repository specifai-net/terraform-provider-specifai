terraform {
  required_providers {
    specifai = {
      source = "specifai-net/terraform/specifai"
    }
  }
}

provider "specifai" {
  region = "eu-west-1"
}

# data "specifai_quicksight_dashboard" "test" {
#   dashboard_id = "a775daeb-5263-4fb2-9f29-815c066bae76"
# }

data "specifai_normalized_dashboard_definition" "test" {
  definition = <<EOT
{
  "DataSetIdentifierDeclarations": [
    {
      "Identifier": "DSS/parking_transactions/1",
      "DataSetArn": "arn:aws:quicksight:eu-west-1:296896140035:dataset/1c3fba16-1167-4a44-8b9a-67b8c8f31257"
    }
  ],
  "Sheets": [
    {
      "SheetId": "1bf00b25-e11c-4c72-877f-8ef82d6f2f8b_0ccaa530-1c37-4321-9e0d-f6368991a045",
      "Name": "Transactions",
      "Visuals": [
        {
          "LineChartVisual": {
            "VisualId": "1bf00b25-e11c-4c72-877f-8ef82d6f2f8b_d4a14e27-96b4-4e8b-9f06-6db1e3f98c77",
            "Title": {
              "Visibility": "VISIBLE"
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "ChartConfiguration": {
              "FieldWells": {
                "LineChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.product.0.1703068894131",
                        "Column": {
                          "DataSetIdentifier": "DSS/parking_transactions/1",
                          "ColumnName": "product"
                        }
                      }
                    }
                  ],
                  "Values": [
                    {
                      "CategoricalMeasureField": {
                        "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.transactionid.1.1703068907396",
                        "Column": {
                          "DataSetIdentifier": "DSS/parking_transactions/1",
                          "ColumnName": "transactionid"
                        },
                        "AggregationFunction": "COUNT"
                      }
                    }
                  ],
                  "Colors": []
                }
              },
              "SortConfiguration": {
                "CategorySort": [
                  {
                    "FieldSort": {
                      "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.transactionid.1.1703068907396",
                      "Direction": "DESC"
                    }
                  }
                ],
                "CategoryItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "ColorItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Type": "STACKED_AREA",
              "XAxisLabelOptions": {
                "AxisLabelOptions": [
                  {
                    "CustomLabel": "Product",
                    "ApplyTo": {
                      "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.product.0.1703068894131",
                      "Column": {
                        "DataSetIdentifier": "DSS/parking_transactions/1",
                        "ColumnName": "product"
                      }
                    }
                  }
                ]
              },
              "PrimaryYAxisLabelOptions": {
                "AxisLabelOptions": [
                  {
                    "CustomLabel": "Transactions",
                    "ApplyTo": {
                      "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.transactionid.1.1703068907396",
                      "Column": {
                        "DataSetIdentifier": "DSS/parking_transactions/1",
                        "ColumnName": "transactionid"
                      }
                    }
                  }
                ]
              },
              "DataLabels": {
                "Visibility": "HIDDEN",
                "Overlap": "DISABLE_OVERLAP"
              },
              "Tooltip": {
                "TooltipVisibility": "VISIBLE",
                "SelectedTooltipType": "DETAILED",
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipTitleType": "PRIMARY_VALUE",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.product.0.1703068894131",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "eed9d271-d0e3-414a-b56f-c2b98ffa1223.transactionid.1.1703068907396",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ]
                }
              }
            },
            "Actions": [],
            "ColumnHierarchies": []
          }
        }
      ],
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ElementId": "1bf00b25-e11c-4c72-877f-8ef82d6f2f8b_d4a14e27-96b4-4e8b-9f06-6db1e3f98c77",
                  "ElementType": "VISUAL",
                  "ColumnSpan": 18,
                  "RowSpan": 12
                }
              ],
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "ResizeOption": "FIXED",
                  "OptimizedViewPortWidth": "1600px"
                }
              }
            }
          }
        }
      ],
      "ContentType": "INTERACTIVE"
    }
  ],
  "CalculatedFields": [],
  "ParameterDeclarations": [],
  "FilterGroups": [],
  "AnalysisDefaults": {
    "DefaultNewSheetConfiguration": {
      "InteractiveLayoutConfiguration": {
        "Grid": {
          "CanvasSizeOptions": {
            "ScreenCanvasSizeOptions": {
              "ResizeOption": "FIXED",
              "OptimizedViewPortWidth": "1600px"
            }
          }
        }
      },
      "SheetContentType": "INTERACTIVE"
    }
  },
  "Options": {
    "WeekStart": "SUNDAY"
  }
}
EOT
}

resource "specifai_quicksight_dashboard" "test" {
  dashboard_id        = "terraform-provider-test-dashboard"
  name                = "Terraform Provider Test Dashboard"
  version_description = "..."
  definition          = data.specifai_normalized_dashboard_definition.test.normalized_definition
}

resource "specifai_quicksight_dashboard_permission" "test" {
  dashboard_id = "terraform-provider-test-dashboard"
  principal    = "arn:aws:quicksight:eu-west-1:296896140035:user/default/quicksight_sso/marcel@meulemans.engineering"
  actions = [
    "quicksight:DescribeDashboard",
    "quicksight:ListDashboardVersions",
    "quicksight:QueryDashboard"
  ]
}

# output "dashboard" {
#   value = data.specifai_quicksight_dashboard.test
# }

# output "definition" {
#   value = data.specifai_normalized_dashboard_definition.test
# }

output "permission" {
  value = specifai_quicksight_dashboard_permission.test.actions
}
