terraform {
  required_providers {
    specifai = {
      source = "specifai.eu/terraform/specifai"
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
  "AnalysisDefaults": {
    "DefaultNewSheetConfiguration": {
      "InteractiveLayoutConfiguration": {
        "Grid": {
          "CanvasSizeOptions": {
            "ScreenCanvasSizeOptions": {
              "ResizeOption": "RESPONSIVE"
            }
          }
        }
      },
      "SheetContentType": "INTERACTIVE"
    }
  },
  "CalculatedFields": [
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "ifelse(\n    manuallyscanned = 1,\n    1,\n    0\n)",
      "Name": "scanerror"
    },
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "concat(\"https://login.sequrix.com/#/Task/Details/\", toString(taskid))",
      "Name": "taskLink"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    traveltime > {maxtraveltime (with default)},\r\n    taskid,\r\n    NULL\r\n)",
      "Name": "Stefan - Traveltime exceeded geef id terug wegen dubble id"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(taskstate = \"Finished\", taskid, NULL)",
      "Name": "Stefan - afgeronde alarmen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNotNull(started) AND isNotNull(ended) AND \r\nended<= blockendtime, taskid, NULL)",
      "Name": "Stefan - taak te laat uitgevoerd"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNotNull(started) AND isNotNull(ended) AND \r\ndateDiff(blockstarttime, started, \"MI\") > -30, taskid, NULL)",
      "Name": "Stefan - taak te vroeg begonnen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(taskstate = \"Aborted\", taskid, NULL)",
      "Name": "Stefan - taskstateAborted"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\nisNotNull(started) AND \r\nisNotNull(ended) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(blockstarttime) AND \r\nstarted < blockstarttime, \"te vroeg begonnen\",\r\nended > blockendtime, \"te laat gestopt\",\r\nstarted > blockstarttime,\"Op tijd begonnen\",\r\nended > blockendtime,\"Op juiste tijd gestopt\",\r\nNULL\r\n)",
      "Name": "Stefan - volgens rooster per catorgory"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\ncontains(workshiftname, 'Avond') = TRUE, \"Avonddienst\",\r\ncontains(workshiftname, 'avond') = TRUE, \"Avonddienst\",\r\ncontains(workshiftname, 'nacht') = TRUE, \"Nachtdienst\",\r\ncontains(workshiftname, 'Dag') = TRUE, \"Dagdienst\",\r\ncontains(workshiftname, 'dag') = TRUE, \"Dagdienst\",\r\ncontains(workshiftname, 'nacht') = TRUE, \"Dagdienst\",\r\ncontains(workshiftname, 'Nacht') = TRUE, \"Dagdienst\",\r\n\r\nNULL\r\n)",
      "Name": "Stefan -workshift(avond/dag/nacht)"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    extract('HH', started) > 9,\r\n    toString(extract('HH', started)),\r\n    concat('0', toString(extract('HH', started)))\r\n)",
      "Name": "Stefan started(hour of the day)"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "sum({taskid_correction}*traveltime)/distinct_count(taskid)",
      "Name": "avg traveltime"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "dateDiff(started, ended, \"MI\")",
      "Name": "duur_werkzaamheden"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "// Set to a default value of 30 minutes\nifelse(\n    isNotNull(maxtraveltime), maxtraveltime,\n    {alarmtype prio} = 'Prio-1', 30.0,\n    {alarmtype prio} = 'Prio-2', 60.0,\n    NULL\n)",
      "Name": "maxtraveltime (with default)"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse( taskid / traveltime = 1, traveltime, NULL)",
      "Name": "stefan  - test veld"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNotNull(started) AND isNotNull(ended) AND \r\ndateDiff(blockstarttime, started, \"MI\") > -30 AND ended< blockendtime, taskid, NULL)",
      "Name": "stefan % geplande task niet volgens rooster"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(workshiftactualended>=workshiftended, 0 ,dateDiff(workshiftactualended, workshiftended, \"MI\") )",
      "Name": "stefan - Datediff te vroeg gestopt"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(workshiftactualstarted <= workshiftstarted, 0 ,dateDiff(workshiftstarted, workshiftactualstarted, \"MI\") )",
      "Name": "stefan - Datediff-te laat begonnen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNotNull(ended) AND \r\nduration> {duur_werkzaamheden}, taskid, NULL)",
      "Name": "stefan - Duur werkzaamheden overschreden %"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(count(taskid) = 1 , 0, count(taskid))",
      "Name": "stefan - countovertest"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "// \r\ndistinct_count({stefan % geplande task niet volgens rooster}) / distinct_count(ifelse(\r\nisNotNull(blockstarttime) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(started) AND \r\nisNotNull(ended)\r\n,taskid, NULL))",
      "Name": "stefan - percentage begonnen task buiten geplande tijd"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count({stefan - Duur werkzaamheden overschreden %}) / distinct_count(ifelse(\r\nisNotNull({duur_werkzaamheden}) AND \r\nisNotNull(blockstarttime) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(started) AND \r\nisNotNull(ended)\r\n, taskid, NULL))",
      "Name": "stefan - percentage werkzaamheden overschreden"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "rank([traveltime ASC], [maxtraveltime], PRE_FILTER)",
      "Name": "stefan - rank traveltime"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    extract('WD', addDateTime(-1, 'DD', started))=1, '1 - Ma',\r\n    extract('WD', addDateTime(-1, 'DD', started))=2, '2 - Di',\r\n    extract('WD', addDateTime(-1, 'DD', started))=3, '3 - Wo',\r\n    extract('WD', addDateTime(-1, 'DD', started))=4, '4 - Do',\r\n    extract('WD', addDateTime(-1, 'DD', started))=5, '5 - Vr',\r\n    extract('WD', addDateTime(-1, 'DD', started))=6, '6 - Za',\r\n    '7 - Zo'\r\n)",
      "Name": "stefan - started(day of the week"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "dateDiff(blockstarttime, started, \"MI\")",
      "Name": "stefan - test1"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "{stefan - rank traveltime} / traveltime",
      "Name": "stefan - travel time gedeeld door id"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    traveltime >= {maxtraveltime (with default)},\r\n    \"Te laat\",\r\n    \"Op tijd\"\r\n)",
      "Name": "stefan - travetime te vroeg begonnen / telaat"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\nworkshiftname=\"1e auto Flevoland avonddienst\" OR workshiftname=\"1e auto Flevoland weekend avonddienst\" OR workshiftname=\"Carbogen Avond\" OR workshiftname=\"2e avond Veenendaal\" OR workshiftname=\"Giant avonddienst\" OR workshiftname=\"Signaal to do avond\" OR workshiftname=\"WBVR Avond\" OR workshiftname=\"WBVR weekend avond\", \"Avonddienst\",\r\n\r\nworkshiftname=\"1e auto Flevoland ochtenddienst\" OR workshiftname=\"Axis ochtend\" OR workshiftname=\"1e auto Flevoland weekend dagdienst\" OR workshiftname=\"1e dagdienst Veenendaal\" OR workshiftname=\"Dagdienst Culemborg\" OR workshiftname=\"Giant dagdienst\", \"Dagdienst\",\r\n\r\nworkshiftname=\"1e auto Flevoland weekend nachtdienst\" OR workshiftname=\"Carbogen Nacht\" OR workshiftname=\"Signaal to do nacht\" OR workshiftname=\"WBVR nacht\" OR workshiftname=\"WBVR weekend nacht\", \"Nachtdienst\",\r\nNULL\r\n\r\n)",
      "Name": "stefan - workshift(dag/avond/nacht)"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "1/countOver(taskid, [taskid],PRE_AGG)",
      "Name": "taskid_correction"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\n    traveltime > {maxtraveltime (with default)},\n    1,\n    0\n)",
      "Name": "traveltime exceeded"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "turnover*{taskid_correction}",
      "Name": "turnover_corrected"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\n    extract('WD', addDateTime(-1, 'DD', workshiftended))=1, '1 - Ma',\n    extract('WD', addDateTime(-1, 'DD', workshiftended))=2, '2 - Di',\n    extract('WD', addDateTime(-1, 'DD', workshiftended))=3, '3 - Wo',\n    extract('WD', addDateTime(-1, 'DD', workshiftended))=4, '4 - Do',\n    extract('WD', addDateTime(-1, 'DD', workshiftended))=5, '5 - Vr',\n    extract('WD', addDateTime(-1, 'DD', workshiftended))=6, '6 - Za',\n    '7 - Zo'\n)",
      "Name": "workshift - day of the week"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "sum(turnover) / sum(workshifttotalhours)",
      "Name": "workshift turnover per hour"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(workshiftactualstarted>workshiftstarted OR workshiftactualended<workshiftended,workshiftid, NULL)",
      "Name": "workshift_binnenRooster"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count({workshift_binnenRooster}) / distinct_count(ifelse(\r\nisNotNull(workshiftactualended) AND \r\nisNotNull(workshiftactualstarted) AND \r\nisNotNull(workshiftstarted) AND \r\nisNotNull(workshiftended)\r\n,workshiftid, NULL))",
      "Name": "workshift_teLaatBegonnen_teVroegGestopt %"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "//De workshift_correction geeft aan door hoeveel gedeeld moet worden om dubbele id's te corrigeren\r\n//Het ifelse statement geeft weer hoeveel minuten iemand te laat aan de dienst begonnen is.\r\n//Er wordt gedeelt door het totaal aantal verschillende workshifts om een juist gemiddelde te krijgen\r\nsum({workshiftid_correction(workshiftid_employee)}*dateDiff(workshiftstarted,workshiftactualstarted, \"MI\"))/distinct_count(workshiftid)",
      "Name": "workshiftactualstarted_telaat_avg"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\n    isNotNull(parseInt(left(workshiftgroupname, 2))),\n    toString(parseInt(left(workshiftgroupname, 2))),\n    workshiftgroupname\n)",
      "Name": "workshiftgroup"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "split(workshiftname, \" \", 1)",
      "Name": "workshiftgroupname"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "avgOver(dateDiff(workshiftstarted, workshiftended, \"MI\") / 60, [workshiftid], PRE_FILTER)",
      "Name": "workshifthours"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "//Hier partitioneren we per workshiftid en employee om tot de juiste correctiefactor te komen\r\n1/countOver(workshiftid, [workshiftid, employee],PRE_AGG)",
      "Name": "workshiftid_correction(workshiftid_employee)"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(maxOver(taskid, [workshiftid], PRE_AGG) = taskid, workshifthours, NULL)",
      "Name": "workshifttotalhours"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "// This groups the workshifts per 4 weeks\nconcat(\n    toString(extract('YYYY', workshiftstarted)),\n    ' - ',\n    ifelse(\n        (floor(workshiftweeknumber / 4) + 1) < 10,\n        concat(\"0\", toString(floor(workshiftweeknumber / 4) + 1)),\n        toString(floor(workshiftweeknumber / 4) + 1)\n    )\n)",
      "Name": "workshiftweekgroup"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "dateDiff(truncDate('YYYY',workshiftstarted),workshiftstarted,'WK')+1",
      "Name": "workshiftweeknumber"
    }
  ],
  "ColumnConfigurations": [
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "stefan - countovertest",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": null,
      "Role": "DIMENSION"
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "accepted",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "blockendtime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "blockstarttime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "customerid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "ended",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "objectid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "onlocation",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "spenttimeinvoice",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "spenttimetotal",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": null,
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "started",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "taskid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "traveltime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 1
              },
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "turnover",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "CurrencySymbolPlacement": null,
              "CurrencySymbolSpacing": null,
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null,
              "Symbol": "EUR"
            },
            "NumberDisplayFormatConfiguration": null,
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "workshiftactualended",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "workshiftactualstarted",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "workshiftended",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "workshiftid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": null,
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "HIDDEN"
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "workshiftstarted",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "duur_werkzaamheden",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": null,
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "traveltime exceeded",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "workshift turnover per hour",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "CurrencySymbolPlacement": null,
              "CurrencySymbolSpacing": null,
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null,
              "Symbol": "EUR"
            },
            "NumberDisplayFormatConfiguration": null,
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "accuracy",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 1
              },
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "distancetocheckpointlocation",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 1
              },
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "gpsfixdatetime",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "manuallyscanned",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": "NONE",
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": null
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "planningresultcheckpointid",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": null,
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "HIDDEN"
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "scanneddatetime",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": null,
          "NumericFormatConfiguration": null
        },
        "NumberFormatConfiguration": null,
        "StringFormatConfiguration": null
      },
      "Role": null
    },
    {
      "ColorsConfiguration": null,
      "Column": {
        "ColumnName": "taskid",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": null,
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": null,
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": null,
              "NegativeValueConfiguration": null,
              "NullValueFormatConfiguration": null,
              "NumberScale": null,
              "Prefix": null,
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "HIDDEN"
                }
              },
              "Suffix": null
            },
            "PercentageDisplayFormatConfiguration": null
          }
        },
        "StringFormatConfiguration": null
      },
      "Role": null
    }
  ],
  "DataSetIdentifierDeclarations": [
    {
      "DataSetArn": "arn:aws:quicksight:eu-west-1:296896140035:dataset/7c8619fe-bc0c-4f69-9fcd-bb53cdb403a1",
      "Identifier": "sequrix_tasks_records"
    },
    {
      "DataSetArn": "arn:aws:quicksight:eu-west-1:296896140035:dataset/1fcd0913-7dac-4e3f-91b6-bdc8aae5d173",
      "Identifier": "sequrix_planning_records"
    }
  ],
  "FilterGroups": [
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "2d472fcc-b55a-4b4d-a8b4-72651dfb3f97",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "6d23bfaa-a14f-4f1d-a972-09340213cf41"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "d08951e9-3810-4612-bd83-df2efbb34575"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "f077e957-1307-49d9-8c32-677bbf89b488",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "scanneddatetime",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "7a7c54f9-7a8a-4d36-b3ac-1550e57d9705",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "18d84d02-7069-4f51-ade8-17ab7e0d96bb"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "3e3018e4-d7f3-4e7e-b1d0-50e0ba65e777",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "employee"
              }
            },
            "FilterId": "b1c43262-67ea-44aa-8717-763d8037f47f"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "18d84d02-7069-4f51-ade8-17ab7e0d96bb"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "4bf66403-8138-4472-822c-0e59f61bc6c7",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "object"
              }
            },
            "FilterId": "dd8b02b0-3e7f-4f7c-9b02-a4f44a8ca398"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "18d84d02-7069-4f51-ade8-17ab7e0d96bb"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "940a4cfc-696b-462b-b557-d97a3bf3cad5",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "checkpointtypeenumname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "BARCODE",
                  "RFID"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "21596a4a-10e5-4a53-bd71-bf02e71109a5"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "18d84d02-7069-4f51-ade8-17ab7e0d96bb"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "0f46df82-6817-4e5e-9788-be04bbd7cc93",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "d70b5700-b361-4ae5-af70-c101628cb2cf"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "600dcc85-713a-471f-933a-4814b18c4af6"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "59d40ddc-0cfc-43f4-b03c-cf1340f41745",
      "Filters": [
        {
          "RelativeDatesFilter": {
            "AnchorDateConfiguration": {
              "AnchorOption": "NOW"
            },
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "ExcludePeriodConfiguration": {
              "Amount": 1,
              "Granularity": "DAY",
              "Status": "ENABLED"
            },
            "FilterId": "d511a956-e1e3-48dd-91ba-0726ff4a30fb",
            "MinimumGranularity": "DAY",
            "NullOption": "NON_NULLS_ONLY",
            "RelativeDateType": "LAST",
            "RelativeDateValue": 8,
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "76f7fe03-462e-4812-9003-84c8dd919a74"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "398299a1-cbeb-465d-8b32-738110c9b9a5",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "AggregationFunction": {
              "NumericalAggregationFunction": {
                "SimpleNumericalAggregation": "SUM"
              }
            },
            "Column": {
              "ColumnName": "traveltime exceeded",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "6256e0f4-4e62-4fb0-a922-ca596963d016",
            "MatchOperator": "EQUALS",
            "NullOption": "ALL_VALUES",
            "SelectAllOptions": "FILTER_ALL_VALUES"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "4d6aa698-2a28-4731-827d-27fd37bb08e5"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "d46d1f8d-dfcb-4876-9104-c0924c1f6df0",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "26abc830-2066-46ea-9d8d-2d26db081072",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "RollingDate": {
                "Expression": "truncDate('DD', now())"
              }
            },
            "RangeMinimumValue": {
              "RollingDate": {
                "Expression": "addDateTime(-1, 'DD', truncDate('DD', now()))"
              }
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "600dcc85-713a-471f-933a-4814b18c4af6"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "5e1d5004-a7fc-448c-ae96-56f0a42b803e",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "AggregationFunction": {
              "NumericalAggregationFunction": {
                "SimpleNumericalAggregation": "SUM"
              }
            },
            "Column": {
              "ColumnName": "traveltime exceeded",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "3786b2e7-197a-46aa-868e-518cd7ee6e8d",
            "MatchOperator": "EQUALS",
            "NullOption": "ALL_VALUES",
            "SelectAllOptions": "FILTER_ALL_VALUES"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "631cf408-2e3c-4120-a657-c225e3ec1eaa"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "447b8434-b6fd-4751-a6ec-e0999a572a72",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "8c6a9398-c6cc-4345-89d6-3da438ea70cf"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "f0cbc5f5-d6dc-4e39-b730-c13fc27be68e"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ddb1d686-7f01-4a7d-b278-ff5afe7d16eb",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "c00ca6ac-84bf-4781-98bd-69f4fba26095",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "RollingDate": {
                "Expression": "truncDate('DD', now())"
              }
            },
            "RangeMinimumValue": {
              "RollingDate": {
                "Expression": "addDateTime(-1, 'DD', truncDate('DD', now()))"
              }
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "f0cbc5f5-d6dc-4e39-b730-c13fc27be68e"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "1a4f5f86-0864-47ff-ad64-d7be26361cee",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "2b0c3fc8-1847-48e8-8979-1f76efd2954b"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "d9a254e2-f9d5-4358-b8d7-0db49dbf97e3"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "a8a3f0d9-d973-4ed0-8d29-e836d02a2793",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "75be9776-57f0-4e94-b553-9e02c9f33baa",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "RollingDate": {
                "Expression": "truncDate('DD', now())"
              }
            },
            "RangeMinimumValue": {
              "RollingDate": {
                "Expression": "addDateTime(-1, 'DD', truncDate('DD', now()))"
              }
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
              "VisualIds": [
                "d9a254e2-f9d5-4358-b8d7-0db49dbf97e3"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "18fce8e8-5925-4c13-a28d-ce164984e9ff",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "workshiftended",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "3733d9ef-ce19-4955-bb5a-d8af8c398920",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "d0ee2839-1155-4c0b-a2ea-14b03b35772e",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "bd6f2725-608c-4ec3-8732-891d3a10ff8b",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "workshiftname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "shift"
              }
            },
            "FilterId": "70d70f01-a38f-4d7b-a07e-affc50aba548"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "d0ee2839-1155-4c0b-a2ea-14b03b35772e",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "60213b12-87b6-47f0-a351-9e8437c8cca1",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "turnover",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "08118386-bb39-4610-a7d6-d046a8bfedf2",
            "IncludeMaximum": false,
            "IncludeMinimum": false,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimum": {
              "StaticValue": 0
            }
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "d0ee2839-1155-4c0b-a2ea-14b03b35772e",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "177e4083-ebc7-4079-aa26-2df8f8a759ac",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "Column": {
              "ColumnName": "traveltime exceeded",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "bb5e077d-ec3f-4f0d-8458-12d5d46609fe",
            "MatchOperator": "EQUALS",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 1
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "082fe431-240b-4d37-9173-416277acd274"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "c16e315c-e9de-48da-87bb-966e13ff02cf",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "6a0381d8-8b45-4095-9553-f3f0306798e6",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "f822d594-e0d5-41a1-bacf-c5d6899544e4",
                "92addb14-aec8-422f-8958-24a7fc2669aa",
                "6a804d9a-d642-4122-aeca-7ded75898ad5",
                "082fe431-240b-4d37-9173-416277acd274",
                "ba733caf-36ea-45f2-b643-ec9b8a96328b",
                "bdd87f19-9c70-4d29-a079-2ed2c44555e8",
                "d97ebb91-ebce-4aba-b449-8e1f0272fabb",
                "5e9c3845-0a51-4e8f-b8d5-f67ff094736c",
                "b46901af-1417-478a-924b-c2ab8c51d88f",
                "37c85845-07fc-47c8-92c3-13905206b2c2",
                "820eaa0d-6607-442f-932e-fe5e3da03a3c"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "fb68cbf3-82ba-48f2-871d-57c8ed2acd2a",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "productname"
              }
            },
            "FilterId": "8c1bc130-ab2a-40a8-ad3c-96dcf9f9b87b"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "29ac5fde-9822-48d1-804e-e78eb19bf7fa",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "alarmprio"
              }
            },
            "FilterId": "98e4f25d-6651-40df-97db-20177935a03c"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "996b85af-86ca-4006-bea9-5aeb7e9613f5",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "alarmtype"
              }
            },
            "FilterId": "da62b668-c5c6-41d2-b0c3-004f70021757"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "9b7372ee-fb13-4f40-85bc-45a7855d397c",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Prio-1"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "6f3fddbb-5978-41f5-888c-9d403a0546e9"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "820eaa0d-6607-442f-932e-fe5e3da03a3c"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "d99f5be5-ae1c-4251-987c-6bf99b7895bc",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Prio-2"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "0e3b615e-3944-4837-acff-13138ecb34df"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "6a804d9a-d642-4122-aeca-7ded75898ad5"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "98cdffa5-14bf-4670-bc4d-f757bbed59af",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Prio-1"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "1bf402a6-2175-4b43-8076-c18ae1e9042c"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "92addb14-aec8-422f-8958-24a7fc2669aa"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "def89eed-8ae5-4d94-bf2f-67c3ab979d7d",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Prio-2"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "bf7c42be-cb00-49b0-a23a-c03a6a5c5a46"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "f822d594-e0d5-41a1-bacf-c5d6899544e4"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "99916baa-f385-4a7b-8088-0bbde368396d",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Prio-3"
                ],
                "MatchOperator": "DOES_NOT_CONTAIN",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "f31532df-95a5-408a-8373-09ce9cd10280"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "37c85845-07fc-47c8-92c3-13905206b2c2"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "e0e7675e-b1a2-4549-b444-090e8ef0510f",
      "Filters": [
        {
          "RelativeDatesFilter": {
            "AnchorDateConfiguration": {
              "AnchorOption": "NOW"
            },
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "d31b2250-9ee0-4bfb-98db-c96f9f880f80",
            "MinimumGranularity": "DAY",
            "NullOption": "NON_NULLS_ONLY",
            "RelativeDateType": "LAST",
            "RelativeDateValue": 3,
            "TimeGranularity": "MONTH"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": [
                "bd11c048-473c-4445-8259-3ad622f64312"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ac67559e-73fa-4819-8aab-314831d5f65a",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "checkpointtypeenumname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "adab5a20-6896-4058-b42f-fe08a2f5de0a"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": [
                "09204ae0-6632-4dc7-b679-433b669045e4"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "76a48154-5a24-45be-aec8-8809f48b70de",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "Column": {
              "ColumnName": "manuallyscanned",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "67de6a3e-701d-47fb-9206-9bce31f3778c",
            "MatchOperator": "EQUALS",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 1
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": [
                "86f2845d-e3dd-44ef-b8ac-cabd0fda5166"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "94268a68-dc51-4c59-97cb-fb4b1812f3d0",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "scanneddatetime",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "47947351-79d0-44c3-af46-151853ad5f37",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "13b1ff98-4ea8-4108-bb51-8718c167f661",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "employee"
              }
            },
            "FilterId": "a6aa7e12-80ca-4d6e-8ebc-191fdd604aec"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "e7b5eaec-6e4c-465f-9405-9c1ade6c12c8",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "object"
              }
            },
            "FilterId": "3e1510be-8528-4425-aaab-2d39e4f53337"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "58cfa5c6-409a-4dfe-9711-2809698ec707",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "distancetocheckpointlocation",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "99a82506-c9d4-4f3b-99ad-59f88a26ef04",
            "IncludeMaximum": false,
            "IncludeMinimum": false,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimum": {
              "StaticValue": 1000
            }
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": [
                "8b721252-f974-454e-bd79-0e4fb4c856ff"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "6369b941-fc8e-4e72-8282-1446e5e66cb4",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "Column": {
              "ColumnName": "scanerror",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "ea3401b8-37d0-4033-a319-de01409e1eab",
            "MatchOperator": "EQUALS",
            "NullOption": "ALL_VALUES",
            "Value": 1
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": [
                "cda3ade0-5a49-4172-b5e3-e211097f60ca"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "ALL_DATASETS",
      "FilterGroupId": "d27146bb-2cb9-4668-9976-f9c638fef716",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "checkpointtypeenumname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "BARCODE",
                  "RFID"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "2e9a1b30-a89b-43a6-b300-03e0dcd667a8"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "444b8a3a-ffe2-4901-871f-739531dca08c",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Stefan started(hour of the day)",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "04",
                  "05",
                  "06",
                  "07",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "20",
                  "21",
                  "22",
                  "23"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "6424d550-e1c4-4891-acef-0e54181a7d2a"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "2a1d46bf-7951-42ce-a3ff-d4e01e67e135"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "f31583df-b71a-4305-9bf2-dec1c0a4c19a",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "270db690-ed14-41b0-b50e-6d49f17f6b6b"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "5b91633a-99ed-4dbd-9f24-2a25906fd84b"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "783218e8-59fe-4c11-bbbc-6e72aea23dd3",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "workshiftname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "1e auto Flevoland avonddienst",
                  "1e auto Flevoland nachtdienst",
                  "1e auto Flevoland ochtenddienst",
                  "1e auto Flevoland weekend avonddienst",
                  "1e auto Flevoland weekend dagdienst",
                  "1e auto Flevoland weekend nachtdienst",
                  "1e dagdienst Veenendaal",
                  "2e avond Culemborg",
                  "2e avond Veenendaal",
                  "Atlas",
                  "Axis middag",
                  "Axis ochtend",
                  "Axis receptie",
                  "Carbogen Avond",
                  "Carbogen Dag",
                  "Carbogen Nacht",
                  "Dagdienst Culemborg",
                  "Doornpc",
                  "Forum",
                  "Forum weekend",
                  "Giant Avonddienst",
                  "Giant avonddienst",
                  "Giant dagdienst",
                  "Helix pc",
                  "Helix pc weekend laat",
                  "Helix pc weekend vroeg",
                  "Leeuwenborch Receptie",
                  "Leeuwenborch receptie cc",
                  "Leeuwenborch receptie cc zaterdag",
                  "Leeuwenborch receptie pc",
                  "Lumen PC",
                  "Lumen en Gaia cc",
                  "NIOO KNAW",
                  "Objectbeveiliging (zonder uursmelding)",
                  "Orion",
                  "RGF Staffing Shared Services the Netherlands B.V.",
                  "Radix",
                  "Radix weekend",
                  "Signaal to do avond",
                  "Signaal to do dag",
                  "Signaal to do nacht",
                  "TEST Objectbeveiliging (zonder uursmelding)",
                  "Vitae",
                  "Vitae zaterdag",
                  "WBVR Avond",
                  "WBVR nacht",
                  "WBVR weekend avond",
                  "WBVR weekend dag",
                  "WBVR weekend nacht",
                  "Weekend 1e dag Culemborg",
                  "helix",
                  "lumen en Gaia cc"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "fffdac11-05b9-4af2-82d3-a257b391b043"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "5b91633a-99ed-4dbd-9f24-2a25906fd84b"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "dd082cd5-00a7-4afd-b579-9fb286db0592",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "stefan - workshift(dag/avond/nacht)",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Avonddienst",
                  "Dagdienst",
                  "Nachtdienst"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "e11f8ef2-3a87-4c91-b05e-1cdcf22b5eaf"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "24381326-615b-4736-8072-d41abaf2e0b5"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "0eb4208c-02bc-4f5b-8e45-f9fdeb53aa6a",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "stefan - workshift(dag/avond/nacht)",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Avonddienst",
                  "Dagdienst",
                  "Nachtdienst"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "7b0c1a96-c176-4c06-8974-49ac3e2b0e55"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "73001c5f-a33e-471a-98a4-acc57015733e"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "6c014705-9975-4bbd-8448-280ec3e10c22",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Stefan -workshift(avond/dag/nacht)",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "e46c76ab-8a99-4567-b013-e8c881afcb78"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "24381326-615b-4736-8072-d41abaf2e0b5"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "cf323fae-ebb2-4da1-917d-6383f8aaf8db",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Stefan -workshift(avond/dag/nacht)",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Avonddienst",
                  "Dagdienst",
                  "Nachtdienst"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "51852635-e8eb-4b09-9dfc-952206d8ee80"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "73001c5f-a33e-471a-98a4-acc57015733e"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "a5474cc2-ed3e-4fdb-aec1-38bf5e512829",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "workshiftname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "6244ebd6-ffd6-4ae4-a052-7877de529796"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "24381326-615b-4736-8072-d41abaf2e0b5"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "aff61f09-a468-4f78-8105-d46a2a190cc1",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "be0a0250-cd9f-4c78-a505-ad1bf2e3de1c"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "113ee7f1-598f-43e8-98b3-9ec7f1534d8a",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "taskstate",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Aborted",
                  "Finished",
                  "Unfinished"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "1d4200c6-23dd-4028-ad40-7af812bee783"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ec40bfbe-8511-4d08-999e-1a99d857f4a3",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "5083ec1b-b249-4995-bc20-7547bd587ff0"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "b7dace93-4e22-4938-a070-32155d0f79b4",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Alarmopvolging"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "5359175a-e3be-4d31-be1e-10ceba4d1617"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "bef5fc33-bbbc-4e7b-a226-ec315b52d23b"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "fda84c26-ff0a-4e99-ac8a-e3aa7d8de9c7",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "8e110c8b-e765-4744-8dd1-82de9c6156df"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "0ad13c07-284a-4717-846b-cabffea655eb",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "f8c4411b-97f7-44b9-b11f-8d4c088e38e9"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "5bd616c9-f4be-4c5b-8f95-446a83bcb22c",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Alarmopvolging"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "ecc7e953-b2ff-47bd-9aa1-29c8a47ca7db"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "f79ed0a5-e410-4c65-b4a5-0c300250fe93"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "146b6d80-796c-4f59-b1ad-c4a7a38c936c",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "traveltime",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "be481dea-30ed-4222-a2b9-539f4ce777f4"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "96616884-d1bf-4bad-a2b6-b3f279b8c662"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "158b0f8e-a03b-4af0-b61f-429eaa4c5026",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "1f423b32-b9fc-488d-8710-0c0d5af01aab"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "96616884-d1bf-4bad-a2b6-b3f279b8c662"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "205fd9ea-f187-43d0-a5c7-37a8dca10333",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "ended",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "ab3d989d-310c-4c06-9df8-1b97420ef741",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "d0ee2839-1155-4c0b-a2ea-14b03b35772e",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "debc94f2-9404-4596-bd8c-d954a1ce1cf4",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "b3723b13-f0a9-4429-a3c0-43333ff40c23"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "abf8e82f-7f0e-4050-ab18-a9b4414b838c"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ee273da8-8ab6-49c9-8b2c-b9725e1c6284",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "f445e472-59f7-4695-aa3d-a7a879841a33",
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimumValue": {
              "StaticValue": "2010-09-01T00:00:00.000Z"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "73001c5f-a33e-471a-98a4-acc57015733e"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "7e8ef3c2-1ace-42a3-abbf-a1923c25d0b7",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "a6f2d705-3d1e-4cc2-871b-ccf3faf92a97"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "3c5541c2-c3ba-443a-a962-5d78ba20684c"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "3d6cf073-8bf6-4129-8519-9df4d08515de",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "workshiftended",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "d6cf96c7-19db-4c41-9dc2-0103b4a6ddd7",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "e31f0c39-6c6f-41f1-ae75-407be693af41",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "workshifttype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Surveillance (met alarmen)"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "aebc11ba-23b5-470e-a814-6df2a769cba0"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "f2c2047f-71c5-4c58-912b-4c821f835131",
              "VisualIds": [
                "e7253333-19b5-47e7-b4be-558eb5366623"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "5e406a1e-4231-4e7e-8c1d-b90bf79ee42d",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "taskstate",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Finished"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "e5b7faa9-ab4c-4729-b67f-a52ba3938cb9"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "d0ee2839-1155-4c0b-a2ea-14b03b35772e",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "829c89d7-b774-4624-b1c6-a66c55580990",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Stefan started(hour of the day)",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "00",
                  "01",
                  "02",
                  "03",
                  "04",
                  "05",
                  "06",
                  "07",
                  "08",
                  "09",
                  "10",
                  "11",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "19",
                  "20",
                  "21",
                  "22",
                  "23"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "3d794fb3-11f0-4834-805a-f405aa99cf40"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
              "VisualIds": [
                "2a1d46bf-7951-42ce-a3ff-d4e01e67e135"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "3cde93ae-3624-4d38-8231-a7c915383dd0",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Beheer brandmeldinstallatie",
                  "Beheer en rapportage",
                  "Brand- en sluitronde",
                  "Brand- en sluitronde op verzoek",
                  "Calamiteitdienst",
                  "Camera Toezicht Centrale OCL",
                  "Camera Toezicht Centrale Schipper Security",
                  "Cameraverificatie",
                  "Checkpoint controle",
                  "Collectief",
                  "Controleronde op verzoek",
                  "Externe controleronde",
                  "Extra dienstverlening WUR",
                  "Interne controleronde",
                  "Man-down systeem",
                  "Meldkameraansluiting",
                  "Noodoproep",
                  "Objectbeveiliging",
                  "Openen op verzoek",
                  "Openingsbegeleiding",
                  "Openingsronde",
                  "Rapportage",
                  "Receptie / Vaste post",
                  "Sluitbegeleiding",
                  "Sluiten op verzoek",
                  "Visitatie"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "89ce4fbb-f5d5-4d8b-b525-61e39e3a35a5"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "f2c2047f-71c5-4c58-912b-4c821f835131",
              "VisualIds": [
                "e7253333-19b5-47e7-b4be-558eb5366623"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "131eaaff-e852-4648-8aab-0f0ecbaef0db",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "4e3855b3-6f1c-4ceb-88d7-893a1456bbd7",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimum": {
              "StaticValue": 0
            }
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "6d4c1e21-dea8-40cf-be24-d7886a82124b"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "0f225178-db5a-4b8f-81eb-a58a35dcd97b",
      "Filters": [
        {
          "RelativeDatesFilter": {
            "AnchorDateConfiguration": {
              "AnchorOption": "NOW"
            },
            "Column": {
              "ColumnName": "workshiftactualended",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "74a2d144-8868-4c2c-a90c-c74a7e7c869b",
            "MinimumGranularity": "HOUR",
            "NullOption": "NON_NULLS_ONLY",
            "RelativeDateType": "LAST",
            "RelativeDateValue": 48,
            "TimeGranularity": "HOUR"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "f2c2047f-71c5-4c58-912b-4c821f835131",
              "VisualIds": [
                "e7253333-19b5-47e7-b4be-558eb5366623"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "4e6e8148-36f1-4f22-a4a6-41259659e817",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "stefan - percentage werkzaamheden overschreden",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "19886f75-3976-4ed7-9b12-41e2f6a37123",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimum": {
              "StaticValue": 0
            }
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "7f1ae92d-de1c-4902-b2bf-1b812fef0d7e"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "46d3d91e-f7e1-416c-8f16-5d9b4eb8df5e",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "CategoryValue": "",
                "MatchOperator": "DOES_NOT_EQUAL",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "19616a63-0367-40c3-a188-7037332641fe"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "6d4c1e21-dea8-40cf-be24-d7886a82124b",
                "3c5541c2-c3ba-443a-a962-5d78ba20684c",
                "96616884-d1bf-4bad-a2b6-b3f279b8c662",
                "abf8e82f-7f0e-4050-ab18-a9b4414b838c",
                "7f1ae92d-de1c-4902-b2bf-1b812fef0d7e"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "55ef5bfb-616c-4e70-8611-d586ccfb7f37",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Beheer brandmeldinstallatie",
                  "Beheer en rapportage",
                  "Brand- en sluitronde",
                  "Brand- en sluitronde op verzoek",
                  "Calamiteitdienst",
                  "Camera Toezicht Centrale OCL",
                  "Camera Toezicht Centrale Schipper Security",
                  "Cameraverificatie",
                  "Checkpoint controle",
                  "Collectief",
                  "Controleronde op verzoek",
                  "Externe controleronde",
                  "Extra dienstverlening WUR",
                  "Interne controleronde",
                  "Man-down systeem",
                  "Meldkameraansluiting",
                  "Noodoproep",
                  "Objectbeveiliging",
                  "Openen op verzoek",
                  "Openingsbegeleiding",
                  "Openingsronde",
                  "Rapportage",
                  "Receptie / Vaste post",
                  "Sluitbegeleiding",
                  "Sluiten op verzoek",
                  "Visitatie"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "6b28a9bf-4d78-4874-a505-c89d692d6317"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": [
                "849a8d42-8732-48b1-af55-7dd2e642fb3e"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "f1378528-ea7c-4f70-8af5-0be3a398d26e",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "regionname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "33ed881d-e3a1-45c0-b4a7-e48dc9c0916f"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "f2c2047f-71c5-4c58-912b-4c821f835131",
              "VisualIds": [
                "e7253333-19b5-47e7-b4be-558eb5366623"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "a3e2907a-5012-4637-8ef4-9cd1a459ec06",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Alarmopvolging"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "f5eaced0-91c1-4b39-9a3b-2adc36df0275"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "06775790-5aed-445a-bc76-309219a4582e"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "e93f2444-d87c-405b-b00a-d2861324d067",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "6cbd8492-b217-40ba-8ed9-326c5aee14e7"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "7b86b80f-d39d-42b3-b3fa-c6bf4d858379",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype prio",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "8ec94746-ce5c-456b-a299-d8be5ab520fe"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "e24ae003-06b3-4565-a311-3d1f796f223e",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Alarmopvolging"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "a9e76326-440a-4857-ad40-35d39f5f0ff5"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "35f3f904-5896-4cd7-8a0a-5655ece43c14"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "c601df9e-b216-4ac7-b1eb-687c6a1556ac",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "traveltime",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "de27df12-c814-498f-85ce-fdeec67860b6"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "29f66f38-c7dd-40fa-a631-d98ecd66d9ac"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "35a9945f-96dc-4766-95a8-5f21795dda67",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "alarmtype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "230V uitval",
                  "Accu laag",
                  "Assistentie aanvraag en begeleiding WA",
                  "BMC storing",
                  "Brandalarm",
                  "Dienstverlening",
                  "Geen testmelding ontvangen",
                  "Inbraakalarm",
                  "Inschakelfout",
                  "Lijnuitval",
                  "Overval / paniekalarm",
                  "Sabotage alarm",
                  "Te laat in",
                  "Technisch alarm",
                  "Technische storing",
                  "Testalarm",
                  "Verboden uit",
                  "Video alarm"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "ca29cc86-3f35-4b19-9675-2e7da3002e9b"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "29f66f38-c7dd-40fa-a631-d98ecd66d9ac"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "001d5d2d-e3d6-48de-b6c6-8999996c0447",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "0cf8e8a0-6ce6-4a4b-b284-64bccec54153"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "f12ec4eb-7f6a-4924-b96e-0442be0c89a9"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "fd4b1c8e-5159-4a06-b388-093784213f28",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "workshiftended",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "8e7b13c6-8b07-4aec-b5e6-f898b77dfee9",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "018068d8-7e4b-4edb-8ea6-61f4e3fa8748",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "a996e7a3-7662-4dd3-8e31-58b2d3bb6bd3",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimum": {
              "StaticValue": 0
            }
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "01f47ef0-4de0-4951-aabb-1a9d06de6487"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "839d164f-d780-4554-b340-a4e500c2d635",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "stefan - percentage werkzaamheden overschreden",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "8201c09e-c21f-48aa-915f-fb28d9498f7f",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMinimum": {
              "StaticValue": 0
            }
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "a5b3e433-742e-418d-a55b-1141efd517af"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "708919a8-68ba-4f14-9ff8-7767da076c31",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "productname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Beheer brandmeldinstallatie",
                  "Beheer en rapportage",
                  "Brand- en sluitronde",
                  "Brand- en sluitronde op verzoek",
                  "Calamiteitdienst",
                  "Camera Toezicht Centrale OCL",
                  "Camera Toezicht Centrale Schipper Security",
                  "Cameraverificatie",
                  "Checkpoint controle",
                  "Collectief",
                  "Controleronde op verzoek",
                  "Externe controleronde",
                  "Extra dienstverlening WUR",
                  "Interne controleronde",
                  "Man-down systeem",
                  "Meldkameraansluiting",
                  "Noodoproep",
                  "Objectbeveiliging",
                  "Openen op verzoek",
                  "Openingsbegeleiding",
                  "Openingsronde",
                  "Rapportage",
                  "Receptie / Vaste post",
                  "Sluitbegeleiding",
                  "Sluiten op verzoek",
                  "Visitatie"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "a7408f7a-7930-49b4-b0cf-3fcf92b3951f"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "081274a4-be60-44eb-8054-f4aa26347b52"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "07b92107-30e3-4c05-a803-9a0a02f51306",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "aacba27f-6c99-4aba-9073-7c5993d81dbf"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ef752d62-7e18-4dd0-af60-ac52883dfd81",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "CategoryValue": "",
                "MatchOperator": "DOES_NOT_EQUAL",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "0a29a712-df7a-4d03-963a-ad78f6752bd0"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": [
                "01f47ef0-4de0-4951-aabb-1a9d06de6487",
                "f12ec4eb-7f6a-4924-b96e-0442be0c89a9",
                "29f66f38-c7dd-40fa-a631-d98ecd66d9ac",
                "3771c0ca-c05e-4f7c-a073-70769798f341",
                "a5b3e433-742e-418d-a55b-1141efd517af",
                "eb9d1a73-395a-4ad9-80c8-ba623c5534ae"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "71f3a6de-aede-4960-a9ff-e2d833e76f15",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "fb721ca1-319d-4e06-84d7-0d55902e7537",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ea0e1cdb-3d62-40c3-b6e1-6f7c54a23704",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "6d5d6097-c705-4fb5-bbc0-3b32be65154d",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "end"
            },
            "RangeMinimumValue": {
              "Parameter": "start"
            },
            "TimeGranularity": "DAY"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
              "VisualIds": null
            }
          ]
        }
      },
      "Status": "ENABLED"
    }
  ],
  "ParameterDeclarations": [
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "employee",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "NULL"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Alarmopvolging"
          ]
        },
        "Name": "productname",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "NULL"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "object",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "NULL"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "alarmtype",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "alarmprio",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "shift",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "DateTimeParameterDeclaration": {
        "DefaultValues": {
          "RollingDate": {
            "Expression": "addDateTime(-3, 'MM', truncDate('MM', now()))"
          },
          "StaticValues": []
        },
        "Name": "start",
        "TimeGranularity": "MINUTE"
      }
    },
    {
      "DateTimeParameterDeclaration": {
        "DefaultValues": {
          "RollingDate": {
            "Expression": "truncDate('DD', now())"
          },
          "StaticValues": []
        },
        "Name": "end",
        "TimeGranularity": "MINUTE"
      }
    }
  ],
  "Sheets": [
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "ResizeOption": "RESPONSIVE"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 9,
                  "ElementId": "d08951e9-3810-4612-bd83-df2efbb34575",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 9,
                  "ColumnSpan": 9,
                  "ElementId": "4d6aa698-2a28-4731-827d-27fd37bb08e5",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 9,
                  "ElementId": "ab33bf91-e3cb-4a02-84a3-aa0b336dcfa7",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 27,
                  "ColumnSpan": 9,
                  "ElementId": "631cf408-2e3c-4120-a657-c225e3ec1eaa",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 9,
                  "ElementId": "600dcc85-713a-471f-933a-4814b18c4af6",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 5
                },
                {
                  "ColumnIndex": 9,
                  "ColumnSpan": 9,
                  "ElementId": "d9a254e2-f9d5-4358-b8d7-0db49dbf97e3",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 5
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 9,
                  "ElementId": "18d84d02-7069-4f51-ade8-17ab7e0d96bb",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 5
                },
                {
                  "ColumnIndex": 27,
                  "ColumnSpan": 9,
                  "ElementId": "f0cbc5f5-d6dc-4e39-b730-c13fc27be68e",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 5
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "76f7fe03-462e-4812-9003-84c8dd919a74",
                  "ElementType": "VISUAL",
                  "RowIndex": 8,
                  "RowSpan": 6
                }
              ]
            }
          }
        }
      ],
      "Name": "KPI",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "9f3bc1a4-e786-4bea-b64a-d5de9c347ef2",
            "SourceParameterName": "start",
            "Title": "Start"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "42e1d308-c39c-4ccb-bfc9-65928330256f",
            "SourceParameterName": "end",
            "Title": "End"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": null,
                  "ColumnSpan": 2,
                  "ElementId": "9f3bc1a4-e786-4bea-b64a-d5de9c347ef2",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": null,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": null,
                  "ColumnSpan": 2,
                  "ElementId": "42e1d308-c39c-4ccb-bfc9-65928330256f",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": null,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "69ab85a7-7820-455f-a2a0-3dd3d167a216",
      "Visuals": [
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "b95cdc15-bf18-49d7-8f77-1ed0e8bae049",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "CategoryLabelVisibility": "VISIBLE",
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1694510461289",
                        "FormatConfiguration": null,
                        "HierarchyId": "61028fdc-7606-45cc-becb-495deec35793"
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "traveltime exceeded",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.1.1694676474881"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.1.1694676474881"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1694510461289",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.1.1694676474881",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "VISIBLE",
                "Visibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [
              {
                "ExplicitHierarchy": {
                  "Columns": [
                    {
                      "ColumnName": "regionname",
                      "DataSetIdentifier": "sequrix_tasks_records"
                    },
                    {
                      "ColumnName": "alarmtype",
                      "DataSetIdentifier": "sequrix_tasks_records"
                    }
                  ],
                  "DrillDownFilters": [],
                  "HierarchyId": "61028fdc-7606-45cc-becb-495deec35793"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal aanrijdtijden overschreden per regio (gisteren)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "d9a254e2-f9d5-4358-b8d7-0db49dbf97e3"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "189b1e7a-3457-413c-b8f6-aafe0edd18f3",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "CategoryLabelVisibility": "VISIBLE",
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.1.1694676322584",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.1.1694676343473"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.1.1694676343473"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.1.1694676322584",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.1.1694676343473",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "VISIBLE",
                "Visibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst per shift (gisteren)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "f0cbc5f5-d6dc-4e39-b730-c13fc27be68e"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "started",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840",
                      "FormatConfiguration": null,
                      "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "turnover",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.1.1694675704917"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "DIFFERENCE"
                },
                "PrimaryValueDisplayType": "COMPARISON",
                "ProgressBar": {
                  "Visibility": "HIDDEN"
                },
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "TooltipVisibility": "HIDDEN",
                  "Type": "AREA",
                  "Visibility": "HIDDEN"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(SUM({turnover}),[SUM({turnover}) DESC],1,[]) > 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(SUM({turnover}),[SUM({turnover}) DESC],1,[]) < 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(SUM({turnover}),[SUM({turnover}) DESC],1,[]) > 0.0",
                        "IconOptions": {
                          "Icon": "CARET_UP"
                        }
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(SUM({turnover}),[SUM({turnover}) DESC],1,[]) < 0.0",
                        "IconOptions": {
                          "Icon": "CARET_DOWN"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst (dag op dag vergelijking)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "631cf408-2e3c-4120-a657-c225e3ec1eaa"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "5a23cfd8-0092-4ace-aa5d-992e688c945a",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "CategoryLabelVisibility": "VISIBLE",
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1694510461289",
                        "FormatConfiguration": null,
                        "HierarchyId": "555c24c8-0559-48ea-ab60-d935a0fe4bcd"
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589729157"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589729157"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589729157",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1694510461289",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "VISIBLE",
                "Visibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [
              {
                "ExplicitHierarchy": {
                  "Columns": [
                    {
                      "ColumnName": "regionname",
                      "DataSetIdentifier": "sequrix_tasks_records"
                    },
                    {
                      "ColumnName": "alarmtype",
                      "DataSetIdentifier": "sequrix_tasks_records"
                    }
                  ],
                  "DrillDownFilters": [],
                  "HierarchyId": "555c24c8-0559-48ea-ab60-d935a0fe4bcd"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal alarmen per regio (gisteren)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "600dcc85-713a-471f-933a-4814b18c4af6"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "71026a5d-22b3-4444-bbe8-b4f7e998eebe",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.0.1641390983698",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "manuallyscanned",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.1.1641390990706"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "212px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "EXCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.1.1641390990706"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "EXCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.0.1641390983698",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.1.1641390990706",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"14px\">Handmatig gescand per locatie</inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "18d84d02-7069-4f51-ade8-17ab7e0d96bb"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "started",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622551003",
                      "FormatConfiguration": null,
                      "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622551003"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "DISTINCT_COUNT"
                      },
                      "Column": {
                        "ColumnName": "taskid",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694614403830"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "COMPARISON",
                "ProgressBar": {
                  "Visibility": "HIDDEN"
                },
                "SecondaryValue": {
                  "Visibility": "VISIBLE"
                },
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "TooltipVisibility": "HIDDEN",
                  "Type": "AREA",
                  "Visibility": "HIDDEN"
                },
                "TrendArrows": {
                  "Visibility": "HIDDEN"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622551003"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622551003"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(DISTINCT_COUNT({taskid}),[DISTINCT_COUNT({taskid}) DESC],1,[]) > 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(DISTINCT_COUNT({taskid}),[DISTINCT_COUNT({taskid}) DESC],1,[]) < 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(DISTINCT_COUNT({taskid}),[DISTINCT_COUNT({taskid}) DESC],1,[]) > 0.0",
                        "IconOptions": {
                          "Icon": "CARET_UP"
                        }
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(DISTINCT_COUNT({taskid}),[DISTINCT_COUNT({taskid}) DESC],1,[]) < 0.0",
                        "IconOptions": {
                          "Icon": "CARET_DOWN"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Totaal aantal Alarmen(dag op dag vergelijking)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "d08951e9-3810-4612-bd83-df2efbb34575"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "started",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840",
                      "FormatConfiguration": null,
                      "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "traveltime exceeded",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.0.1694591852734"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "DIFFERENCE"
                },
                "PrimaryValueDisplayType": "COMPARISON",
                "ProgressBar": {
                  "Visibility": "VISIBLE"
                },
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "TooltipVisibility": "HIDDEN",
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "TrendArrows": {
                  "Visibility": "HIDDEN"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1694622392840"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(SUM({traveltime exceeded}),[SUM({traveltime exceeded}) DESC],1,[]) > 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(SUM({traveltime exceeded}),[SUM({traveltime exceeded}) DESC],1,[]) < 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(SUM({traveltime exceeded}),[SUM({traveltime exceeded}) DESC],1,[]) > 0.0",
                        "IconOptions": {
                          "Icon": "CARET_UP"
                        }
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(SUM({traveltime exceeded}),[SUM({traveltime exceeded}) DESC],1,[]) < 0.0",
                        "IconOptions": {
                          "Icon": "CARET_DOWN"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aanrijdtijden overschreden (dag op dag vergelijking)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "4d6aa698-2a28-4731-827d-27fd37bb08e5"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "BarsArrangement": "STACKED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "DAY",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694596583322",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM-DD-YYYY H:mm",
                          "NullValueFormatConfiguration": null,
                          "NumericFormatConfiguration": null
                        },
                        "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694596583322"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.2.1694611911834",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694596795999"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Width": "179px"
              },
              "Orientation": "VERTICAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694596583322"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694596583322",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694596795999",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.2.1694611911834",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694596583322"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal Taken per productnaam(van de afgelopen week)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "76f7fe03-462e-4812-9003-84c8dd919a74"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "scanneddatetime",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.scanneddatetime.1.1696516590341",
                      "FormatConfiguration": null,
                      "HierarchyId": "ff7374b0-8635-47bd-a87b-3d751f53420b.scanneddatetime.1.1696516590341"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "manuallyscanned",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.manuallyscanned.0.1696516587789"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "DIFFERENCE"
                },
                "PrimaryValueDisplayType": "COMPARISON",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "TooltipVisibility": "HIDDEN",
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.scanneddatetime.1.1696516590341"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "ff7374b0-8635-47bd-a87b-3d751f53420b.scanneddatetime.1.1696516590341"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(SUM({manuallyscanned}),[SUM({manuallyscanned}) DESC],1,[]) > 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(SUM({manuallyscanned}),[SUM({manuallyscanned}) DESC],1,[]) < 0.0"
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#2CAD00",
                        "Expression": "percentDifference(SUM({manuallyscanned}),[SUM({manuallyscanned}) DESC],1,[]) > 0.0",
                        "IconOptions": {
                          "Icon": "CARET_UP"
                        }
                      }
                    }
                  }
                },
                {
                  "ComparisonValue": {
                    "Icon": {
                      "CustomCondition": {
                        "Color": "#DE3B00",
                        "Expression": "percentDifference(SUM({manuallyscanned}),[SUM({manuallyscanned}) DESC],1,[]) < 0.0",
                        "IconOptions": {
                          "Icon": "CARET_DOWN"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "Visibility": "VISIBLE"
            },
            "VisualId": "ab33bf91-e3cb-4a02-84a3-aa0b336dcfa7"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "FilterControls": [
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "8084a406-329d-4163-b7f5-40e56f33c78f",
            "SourceFilterId": "33ed881d-e3a1-45c0-b4a7-e48dc9c0916f",
            "Title": "Regio",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "ResizeOption": "RESPONSIVE"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "e7253333-19b5-47e7-b4be-558eb5366623",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 16
                }
              ]
            }
          }
        }
      ],
      "Name": "Prestatiedashboard",
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": null,
                  "ColumnSpan": 2,
                  "ElementId": "8084a406-329d-4163-b7f5-40e56f33c78f",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": null,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "f2c2047f-71c5-4c58-912b-4c821f835131",
      "Visuals": [
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "863a3ba2-90c7-4b8f-ab33-6693af808718",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.0.1696411037393",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "254px"
                  },
                  {
                    "CustomLabel": "Werknemer",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.6.1697007256431",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "202px"
                  },
                  {
                    "CustomLabel": "Start dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "128px"
                  },
                  {
                    "CustomLabel": "Einde dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "133px"
                  },
                  {
                    "CustomLabel": "Gemiddelde aanrijtijd (min)",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.3.1696412039222",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "155px"
                  },
                  {
                    "CustomLabel": "Overschreden aanrijtijden",
                    "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.5.1696521167406",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "173px"
                  },
                  {
                    "CustomLabel": "Uitgevoerd volgens rooster %",
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "211px"
                  },
                  {
                    "CustomLabel": "Uitvoering binnen Tijdslimit %",
                    "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "241px"
                  },
                  {
                    "CustomLabel": "Opdrachten",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.8.1697014026331",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "119px"
                  },
                  {
                    "CustomLabel": "Afgerond",
                    "FieldId": "c36e82d0-ea12-402f-8861-c1bc34463009.2.1696411698251",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "81px"
                  },
                  {
                    "CustomLabel": "Afgebroken",
                    "FieldId": "833b3e4b-75a7-42ae-98fa-d7c1b1fac8d5.3.1696411904427",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "102px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.0.1696411037393",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.6.1697007256431",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualstarted",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM D, YYYY H:mm",
                          "NullValueFormatConfiguration": null,
                          "NumericFormatConfiguration": null
                        },
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM D, YYYY H:mm",
                          "NullValueFormatConfiguration": null,
                          "NumericFormatConfiguration": null
                        },
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "AVERAGE"
                        },
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.3.1696412039222"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "traveltime exceeded",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.5.1696521167406"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": "%"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan - percentage werkzaamheden overschreden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": "%"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.8.1697014026331"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "Stefan - afgeronde alarmen",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c36e82d0-ea12-402f-8861-c1bc34463009.2.1696411698251"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "Stefan - taskstateAborted",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "833b3e4b-75a7-42ae-98fa-d7c1b1fac8d5.3.1696411904427"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Height": 36
                },
                "HeaderStyle": {
                  "Height": 79,
                  "TextWrap": "WRAP"
                }
              }
            },
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Cell": {
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Gradient": {
                          "Color": {
                            "Stops": [
                              {
                                "Color": "#DE3B00",
                                "DataValue": 0,
                                "GradientOffset": 0
                              },
                              {
                                "Color": "#2CAD00",
                                "DataValue": 0.8,
                                "GradientOffset": 100
                              }
                            ]
                          },
                          "Expression": "{stefan - percentage begonnen task buiten geplande tijd}"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Gradient": {
                          "Color": {
                            "Stops": [
                              {
                                "Color": "#DE3B00",
                                "DataValue": 0,
                                "GradientOffset": 0
                              },
                              {
                                "Color": "#2CAD00",
                                "DataValue": 1,
                                "GradientOffset": 100
                              }
                            ]
                          },
                          "Expression": "{stefan - percentage werkzaamheden overschreden}"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "833b3e4b-75a7-42ae-98fa-d7c1b1fac8d5.3.1696411904427",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#DE3B00",
                          "Expression": "DISTINCT_COUNT({Stefan - taskstateAborted}) > 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Gradient": {
                          "Color": {
                            "Stops": [
                              {
                                "Color": "#2CAD00",
                                "DataValue": 0,
                                "GradientOffset": 0
                              },
                              {
                                "Color": "#DE3B00",
                                "DataValue": 15,
                                "GradientOffset": 100
                              }
                            ]
                          },
                          "Expression": "SUM({stefan - Datediff te vroeg gestopt})"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Gradient": {
                          "Color": {
                            "Stops": [
                              {
                                "Color": "#2CAD00",
                                "DataValue": 0,
                                "GradientOffset": 0
                              },
                              {
                                "Color": "#DE3B00",
                                "DataValue": 15,
                                "GradientOffset": 100
                              }
                            ]
                          },
                          "Expression": "AVG({stefan - Datediff-te laat begonnen})"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "Visibility": "HIDDEN"
            },
            "VisualId": "e7253333-19b5-47e7-b4be-558eb5366623"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 10,
                  "ElementId": "a46b41ab-622f-4b23-ba95-3daa38ba6741",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 8,
                  "ElementId": "200ab1ef-3e7a-42fc-8f44-155c900f4667",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 8,
                  "ElementId": "42be886d-e5c4-4379-a37c-96b08bf76d50",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 26,
                  "ColumnSpan": 10,
                  "ElementId": "de18e771-3e5b-4a82-89f3-5288dfa4922f",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 16,
                  "ElementId": "b57a12f6-d5e2-4621-a5b8-74d247c414ed",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 10,
                  "ElementId": "8d5b64d5-12d0-4a77-9594-5ce35415694b",
                  "ElementType": "VISUAL",
                  "RowIndex": 8,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 26,
                  "ColumnSpan": 10,
                  "ElementId": "79e7ad5b-a3b1-461b-9fff-e6d85801dd68",
                  "ElementType": "VISUAL",
                  "RowIndex": 8,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 16,
                  "ElementId": "5e5097b2-1c5a-4098-bd65-07b500ac06bd",
                  "ElementType": "VISUAL",
                  "RowIndex": 10,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "aed5b2db-557a-47c2-abca-16b7615b3339",
                  "ElementType": "VISUAL",
                  "RowIndex": 18,
                  "RowSpan": 10
                }
              ]
            }
          }
        }
      ],
      "Name": "Opbrengst opvolgingen",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "62a7ec16-8d98-4fcf-a533-bdb2bc9541f8",
            "SourceParameterName": "start",
            "Title": "Vanaf"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "3388f3e4-ae75-4ded-8a34-ee9d7e780d3d",
            "SourceParameterName": "end",
            "Title": "Tot"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "7a88e51f-4247-40d3-ba05-54219adabda0",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "workshiftname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "shift",
            "Title": "Dienst",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetId": "d0ee2839-1155-4c0b-a2ea-14b03b35772e",
      "Visuals": [
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "9ec82847-ff4e-4ca7-84e9-725861b87f93",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "ScrollbarOptions": {
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 9.090909090909092,
                      "To": 100
                    }
                  }
                }
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1696319936158",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Width": "100px"
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1696319936158",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst per regio</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "a46b41ab-622f-4b23-ba95-3daa38ba6741"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "33c8c88a-53ab-4bed-9394-18bf149fbd97",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "ScrollbarOptions": {
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 68.91304347826086,
                      "To": 92.82608695652172
                    }
                  }
                }
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.1.1696316731988",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Width": "100px"
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.1.1696316731988",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "AxisOffset": "193px"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst per object</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5e5097b2-1c5a-4098-bd65-07b500ac06bd"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "turnover",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.0.1695820007226"
                    }
                  }
                ]
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Totale opbrengst</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "200ab1ef-3e7a-42fc-8f44-155c900f4667"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "d84adf3d-b57a-4a53-8ff9-2048db117182",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": " ",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.workshiftname.0.1644590300610",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "241px"
                  },
                  {
                    "CustomLabel": "Opbrengst",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590311711",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Opbrengst per uur",
                    "FieldId": "c2f84137-fda2-4372-9ed0-424932f5c301.3.1644590326522",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "134px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.workshiftname.0.1644590300610",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590311711"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "workshift turnover per hour",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c2f84137-fda2-4372-9ed0-424932f5c301.3.1644590326522"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "c2f84137-fda2-4372-9ed0-424932f5c301.3.1644590326522"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "TextWrap": "NONE"
                },
                "HeaderStyle": {
                  "TextWrap": "WRAP"
                },
                "RowAlternateColorOptions": {
                  "Status": "DISABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  Overzicht per dienst (\n  <parameter>$${start}</parameter>\n   to \n  <parameter>$${end}</parameter>\n  )\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "79e7ad5b-a3b1-461b-9fff-e6d85801dd68"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "workshift turnover per hour",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "c2f84137-fda2-4372-9ed0-424932f5c301.0.1644590115404"
                    }
                  }
                ]
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddele opbrengst per uur</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "42be886d-e5c4-4379-a37c-96b08bf76d50"
          }
        },
        {
          "TableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Dienst",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.workshiftname.0.1644590506801",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "250px"
                  },
                  {
                    "CustomLabel": "Taak",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1644590515643",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Regio",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.2.1644590521350",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Klant",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.customername.3.1644590526863",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "249px"
                  },
                  {
                    "CustomLabel": "Opbrengst",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.5.1644590545005",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.workshiftname.0.1644590506801",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": null,
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.8.1697007061505",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "taskstate",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskstate.6.1697007006890",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1644590515643",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.2.1644590521350",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "customername",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.customername.3.1644590526863",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.5.1696515063000",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "MIN"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.5.1644590545005"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.7.1697007037505"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1644590515643"
                    }
                  }
                ]
              },
              "TableOptions": {
                "HeaderStyle": {
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst per taak</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "aed5b2db-557a-47c2-abca-16b7615b3339"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "065457e7-2e9f-4ee4-a506-3fcbf34bb747",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.regionname.1.1695816743096",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Width": "100px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.regionname.1.1695816743096",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst per regio</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "8d5b64d5-12d0-4a77-9594-5ce35415694b"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshift - day of the week",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "198456d2-1eaf-4dc5-88e4-2afaf4d5b8b1.0.1645540501397",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "workshift turnover per hour",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c2f84137-fda2-4372-9ed0-424932f5c301.1.1645540549712"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Width": "102px"
              },
              "Orientation": "VERTICAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "198456d2-1eaf-4dc5-88e4-2afaf4d5b8b1.0.1645540501397"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "198456d2-1eaf-4dc5-88e4-2afaf4d5b8b1.0.1645540501397",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "c2f84137-fda2-4372-9ed0-424932f5c301.1.1645540549712",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddelde opbrengst per uur per dag van de week</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "de18e771-3e5b-4a82-89f3-5288dfa4922f"
          }
        },
        {
          "ComboChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "BarDataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "BarsArrangement": "CLUSTERED",
              "FieldWells": {
                "ComboChartAggregatedFieldWells": {
                  "BarValues": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.1.1695818123840"
                      }
                    }
                  ],
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MONTH",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.2.1696516987878",
                        "FormatConfiguration": null,
                        "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.2.1696516987878"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "LineValues": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "workshift turnover per hour",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "8254e1f5-55ca-42cd-897e-715014673790.2.1695819067078"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Width": "180px"
              },
              "LineDataLabels": {
                "Overlap": "DISABLE_OVERLAP"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.2.1696516987878"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.turnover.1.1695818123840",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "8254e1f5-55ca-42cd-897e-715014673790.2.1695819067078",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.2.1696516987878",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.2.1696516987878"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Totale en gemiddelde omzet per uur per maand</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "b57a12f6-d5e2-4621-a5b8-74d247c414ed"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "FilterControls": [
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "570f7e6b-b428-4f24-a708-ce3f4c18bf1c",
            "SourceFilterId": "5083ec1b-b249-4995-bc20-7547bd587ff0",
            "Title": "Aansluiting",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "6a0c7c84-e785-4ac6-b78f-20346bcf23ff",
            "SourceFilterId": "f8c4411b-97f7-44b9-b11f-8d4c088e38e9",
            "Title": "Alarmtype",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "8a642ec2-900e-4ac8-99bb-7617989f54f9",
            "SourceFilterId": "8e110c8b-e765-4744-8dd1-82de9c6156df",
            "Title": "Product",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "ResizeOption": "RESPONSIVE"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 7,
                  "ElementId": "59eea3a8-18f1-4614-9933-3ac50ce25628",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 7,
                  "ColumnSpan": 7,
                  "ElementId": "bef5fc33-bbbc-4e7b-a226-ec315b52d23b",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 8,
                  "ElementId": "d835fed9-ffe3-4c76-8d8b-1c9f6cc6b423",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 7,
                  "ElementId": "5154f693-65c2-424c-9cb4-c217023c11d2",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 29,
                  "ColumnSpan": 7,
                  "ElementId": "3913b0c0-f1e2-44f9-ba49-6a8e90d6d354",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 14,
                  "ElementId": "0aaaeb88-2c8d-4f17-b007-dc5518620ae5",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 8,
                  "ElementId": "04118f42-3b38-4ca3-bd61-31fe9757f44d",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 7,
                  "ElementId": "5ca2b131-f711-4d8c-80c4-67af62c3113d",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 29,
                  "ColumnSpan": 7,
                  "ElementId": "f79ed0a5-e410-4c65-b4a5-0c300250fe93",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 7,
                  "ElementId": "abf8e82f-7f0e-4050-ab18-a9b4414b838c",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 7,
                  "ColumnSpan": 7,
                  "ElementId": "96616884-d1bf-4bad-a2b6-b3f279b8c662",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 8,
                  "ElementId": "3c5541c2-c3ba-443a-a962-5d78ba20684c",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 7,
                  "ElementId": "7f1ae92d-de1c-4902-b2bf-1b812fef0d7e",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 29,
                  "ColumnSpan": 7,
                  "ElementId": "6d4c1e21-dea8-40cf-be24-d7886a82124b",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "849a8d42-8732-48b1-af55-7dd2e642fb3e",
                  "ElementType": "VISUAL",
                  "RowIndex": 16,
                  "RowSpan": 11
                }
              ]
            }
          }
        }
      ],
      "Name": "Aansluitingen",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "358c0a39-afb5-406e-a417-e1cdb9ac6762",
            "SourceParameterName": "start",
            "Title": "Start"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "fb02461a-36cf-4251-ba2d-e24a19a44a63",
            "SourceParameterName": "end",
            "Title": "End"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "358c0a39-afb5-406e-a417-e1cdb9ac6762",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "fb02461a-36cf-4251-ba2d-e24a19a44a63",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "570f7e6b-b428-4f24-a708-ce3f4c18bf1c",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "8a642ec2-900e-4ac8-99bb-7617989f54f9",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "6a0c7c84-e785-4ac6-b78f-20346bcf23ff",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "1ac94cc8-aee8-40cd-86a8-8cc6cfb83c9f",
      "Visuals": [
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "b589bdac-21cd-4bbc-ade8-0a8f2a34b493",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "ID",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "259px"
                  },
                  {
                    "CustomLabel": "Product",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "298px"
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "91px"
                  },
                  {
                    "CustomLabel": "Block starttijd ",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "130px"
                  },
                  {
                    "CustomLabel": "Gestart",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "141px"
                  },
                  {
                    "CustomLabel": "Gestopt",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "142px"
                  },
                  {
                    "CustomLabel": "Block stoptijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "136px"
                  },
                  {
                    "CustomLabel": "Geplande duur",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.12.1698745395841",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Daadwerkelijke duur",
                    "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockstarttime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockendtime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duration",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.12.1698745395841",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duur_werkzaamheden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    }
                  ],
                  "Values": []
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Height": 35
                },
                "HeaderStyle": {
                  "Height": 63,
                  "TextWrap": "WRAP"
                }
              }
            },
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Cell": {
                    "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#219FD7",
                          "Expression": "{stefan - percentage werkzaamheden overschreden} = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#8B5011",
                          "Expression": "COUNT({Stefan - taak te laat uitgevoerd}) = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#8B5011",
                          "Expression": "COUNT({Stefan - taak te vroeg begonnen}) = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#FF8700",
                          "Expression": "DISTINCT_COUNT({Stefan - Traveltime exceeded geef id terug wegen dubble id}) = 1"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#F7E65A",
                          "Expression": "DISTINCT_COUNT({Stefan - Traveltime exceeded geef id terug wegen dubble id}) = 0"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "Visibility": "HIDDEN"
            },
            "VisualId": "849a8d42-8732-48b1-af55-7dd2e642fb3e"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "fb708647-51c7-44e5-bb80-b345a2c72fa8",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.0.1697097742072",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "248px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.1.1697097889565",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.0.1697097742072",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.1.1697097889565",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": "%"
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.1.1697097889565"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#A8577B",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#8B5011",
                  "FontConfiguration": {
                    "FontColor": "#EEEEEE"
                  },
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitgevoerd volgens rooster % per object</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "6d4c1e21-dea8-40cf-be24-d7886a82124b"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "867795dd-a994-4233-a632-5857fa9e5f22",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.1.1696421382963",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "233px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1698694155139",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "109px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.1.1696421382963",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "Stefan - Traveltime exceeded geef id terug wegen dubble id",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1698694155139"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1698694155139"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#FF8700",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 20
                },
                "HeaderStyle": {
                  "BackgroundColor": "#FF8700",
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal aanrijtijden overschreden per object</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "3c5541c2-c3ba-443a-a962-5d78ba20684c"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "e75ad6fc-4b38-43ad-b018-e81fc2024b5d",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "ScrollbarOptions": {
                  "Visibility": "VISIBLE",
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 47.4934036939314,
                      "To": 100
                    }
                  }
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1696490853326",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Position": "RIGHT",
                "Width": "152px"
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1696490853326",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "AxisOffset": "78px",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen per activiteit en alarmtype</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "f79ed0a5-e410-4c65-b4a5-0c300250fe93"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "traveltime exceeded",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.0.1680598668400"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal overschreden aanrijtijden</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "d835fed9-ffe3-4c76-8d8b-1c9f6cc6b423"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "ff6d9832-9c53-42cc-af8e-9a6bf6e33786",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.0.1696412858007",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "213px"
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "32a95a69-0938-4848-9ea2-3ac82f6aa712.2.1698778013133",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.0.1696412858007",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "avg traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "32a95a69-0938-4848-9ea2-3ac82f6aa712.2.1698778013133"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "32a95a69-0938-4848-9ea2-3ac82f6aa712.2.1698778013133"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#F7E65A",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 24
                },
                "HeaderStyle": {
                  "BackgroundColor": "#F7E65A",
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              },
              "TotalOptions": {
                "Placement": "END",
                "TotalsVisibility": "HIDDEN"
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddelde aanrijdtijden per object</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "96616884-d1bf-4bad-a2b6-b3f279b8c662"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "eb7f6c4c-fdf9-4aa3-8bb8-cd85c6ee91a5",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "STACKED",
              "CategoryAxis": {
                "AxisLineVisibility": "HIDDEN",
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MONTH",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718",
                        "FormatConfiguration": null,
                        "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696438800883"
                      }
                    }
                  ]
                }
              },
              "Orientation": "VERTICAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696438800883",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen over tijd (per maand)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "0aaaeb88-2c8d-4f17-b007-dc5518620ae5"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "9fcf4ead-7a0b-4841-9779-03f45c94e0d3",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.1.1696421382963",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "256px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1696421410096",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "61px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.1.1696421382963",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1696421410096"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1696421410096"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#1E1217",
                      "Style": "SOLID",
                      "Thickness": 2
                    }
                  },
                  "FontConfiguration": {},
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#000000",
                  "FontConfiguration": {
                    "FontColor": "#EEEEEE"
                  },
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen per object</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "abf8e82f-7f0e-4050-ab18-a9b4414b838c"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "b130a0c6-206c-456c-9113-c86e8be0cabb",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "ScrollbarOptions": {
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 46.17414248021109,
                      "To": 100
                    }
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.1.1696488812710",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                      }
                    }
                  ]
                }
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.1.1696488812710",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "AxisOffset": "129px",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen per product</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5ca2b131-f711-4d8c-80c4-67af62c3113d"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "AVERAGE"
                      },
                      "Column": {
                        "ColumnName": "traveltime",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.1.1696438556802"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "TooltipVisibility": "HIDDEN",
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddelde aanrijtijd (min)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "bef5fc33-bbbc-4e7b-a226-ec315b52d23b"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "c752caaf-3a06-40bd-a06f-508b88e67fc8",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "taskstate",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskstate.1.1696493774641",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696493783609"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                }
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696493783609"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskstate.1.1696493774641",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696493783609",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Status taken</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "04118f42-3b38-4ca3-bd61-31fe9757f44d"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - percentage werkzaamheden overschreden",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.0.1697097435852",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "SeparatorConfiguration": {
                              "DecimalSeparator": "DOT",
                              "ThousandsSeparator": {
                                "Symbol": "COMMA",
                                "Visibility": "VISIBLE"
                              }
                            },
                            "Suffix": "%"
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitvoering binnen Tijdslimit %</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5154f693-65c2-424c-9cb4-c217023c11d2"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.0.1697097571064",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "SeparatorConfiguration": {
                              "DecimalSeparator": "DOT",
                              "ThousandsSeparator": {
                                "Symbol": "COMMA",
                                "Visibility": "VISIBLE"
                              }
                            },
                            "Suffix": "%"
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitgevoerd volgens rooster %</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "3913b0c0-f1e2-44f9-ba49-6a8e90d6d354"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "05ecdb99-97f4-41f0-b266-2b6f49d8a148",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.0.1697097742072",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "247px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.1.1697097761498",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "61px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.0.1697097742072",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan - percentage werkzaamheden overschreden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.1.1697097761498",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": "%"
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.1.1697097761498"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#219FD7",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#219FD7",
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitvoering binnen Tijdslimit % per object</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "7f1ae92d-de1c-4902-b2bf-1b812fef0d7e"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "DISTINCT_COUNT"
                      },
                      "Column": {
                        "ColumnName": "taskid",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.0.1697183037772"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "59eea3a8-18f1-4614-9933-3ac50ce25628"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "FilterControls": [
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "974d3d16-aaf2-4d4f-a07b-ce74a0a6db4e",
            "SourceFilterId": "8ec94746-ce5c-456b-a299-d8be5ab520fe",
            "Title": "Alarmtype",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "1cbe55fc-68dc-4025-805b-3a9a75072793",
            "SourceFilterId": "6cbd8492-b217-40ba-8ed9-326c5aee14e7",
            "Title": "Product",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "e23917c3-acc3-4934-8c10-a0961aa885b8",
            "SourceFilterId": "aacba27f-6c99-4aba-9073-7c5993d81dbf",
            "Title": "Medewerker",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "ResizeOption": "RESPONSIVE"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 7,
                  "ElementId": "5bfafc2d-1782-4205-860b-298cf0413e0c",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 7,
                  "ColumnSpan": 7,
                  "ElementId": "06775790-5aed-445a-bc76-309219a4582e",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 8,
                  "ElementId": "8b356834-5526-4dea-80d4-8c27e82d3a2e",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 7,
                  "ElementId": "ca222eca-883b-46ab-82de-27dd0055ce2f",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 29,
                  "ColumnSpan": 7,
                  "ElementId": "f1a12147-baa7-43af-ab25-1fd5697a1804",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 14,
                  "ElementId": "a49845d6-e333-4267-95d4-285e770d9f18",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 8,
                  "ElementId": "5fb9eb68-c0b1-4cdb-b059-c6c7e92f8618",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 7,
                  "ElementId": "757ef040-1601-4861-9a42-4bd37304b628",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 29,
                  "ColumnSpan": 7,
                  "ElementId": "35f3f904-5896-4cd7-8a0a-5655ece43c14",
                  "ElementType": "VISUAL",
                  "RowIndex": 2,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 7,
                  "ElementId": "3771c0ca-c05e-4f7c-a073-70769798f341",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 7,
                  "ColumnSpan": 7,
                  "ElementId": "29f66f38-c7dd-40fa-a631-d98ecd66d9ac",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 8,
                  "ElementId": "f12ec4eb-7f6a-4924-b96e-0442be0c89a9",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 7,
                  "ElementId": "a5b3e433-742e-418d-a55b-1141efd517af",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 29,
                  "ColumnSpan": 7,
                  "ElementId": "01f47ef0-4de0-4951-aabb-1a9d06de6487",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "081274a4-be60-44eb-8054-f4aa26347b52",
                  "ElementType": "VISUAL",
                  "RowIndex": 16,
                  "RowSpan": 11
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 10,
                  "ElementId": "eb9d1a73-395a-4ad9-80c8-ba623c5534ae",
                  "ElementType": "VISUAL",
                  "RowIndex": 27,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 26,
                  "ElementId": "f58553a1-52db-4124-a2f4-02d0f3fdb2b7",
                  "ElementType": "VISUAL",
                  "RowIndex": 27,
                  "RowSpan": 7
                }
              ]
            }
          }
        }
      ],
      "Name": "Medewerkers",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "62422652-7928-4daf-a69b-54112e11e5ca",
            "SourceParameterName": "start",
            "Title": "Start"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "237bb522-d7cf-4a48-8f41-62d9c4569889",
            "SourceParameterName": "end",
            "Title": "End"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "62422652-7928-4daf-a69b-54112e11e5ca",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "237bb522-d7cf-4a48-8f41-62d9c4569889",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "e23917c3-acc3-4934-8c10-a0961aa885b8",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "1cbe55fc-68dc-4025-805b-3a9a75072793",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "974d3d16-aaf2-4d4f-a07b-ce74a0a6db4e",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "a4d6712c-a01c-4618-ac28-3b6e84d3eb9f",
      "Visuals": [
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "008174a5-6cd8-43bc-aaf8-17f58ef98927",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064558723",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "168px"
                  },
                  {
                    "CustomLabel": "Minuten",
                    "FieldId": "dde02fd3-c058-4072-8aee-cf59aebf7bc4.1.1700075448936",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064558723",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "workshiftactualstarted_telaat_avg",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "dde02fd3-c058-4072-8aee-cf59aebf7bc4.1.1700075448936"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "dde02fd3-c058-4072-8aee-cf59aebf7bc4.1.1700075448936"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#1E1217",
                      "Style": "SOLID",
                      "Thickness": 2
                    }
                  },
                  "FontConfiguration": {},
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#000000",
                  "FontConfiguration": {
                    "FontColor": "#EEEEEE"
                  },
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddeld te laat begonnen aan dienst</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "eb9d1a73-395a-4ad9-80c8-ba623c5534ae"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "bd2635c8-f9e0-4c54-b5bc-d2c573e1b07c",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "ID",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.10.1700065151677",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "209px"
                  },
                  {
                    "CustomLabel": "Aansluiting",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "233px"
                  },
                  {
                    "CustomLabel": "Product",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "265px"
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "91px"
                  },
                  {
                    "CustomLabel": "Block starttijd ",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "130px"
                  },
                  {
                    "CustomLabel": "Gestart",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "141px"
                  },
                  {
                    "CustomLabel": "Gestopt",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "142px"
                  },
                  {
                    "CustomLabel": "Block stoptijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "136px"
                  },
                  {
                    "CustomLabel": "Geplande duur",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.12.1698745395841",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Daadwerkelijke duur",
                    "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.10.1700065151677",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockstarttime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockendtime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duration",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.12.1698745395841",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duur_werkzaamheden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    }
                  ],
                  "Values": []
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Height": 35
                },
                "HeaderStyle": {
                  "Height": 63,
                  "TextWrap": "WRAP"
                }
              }
            },
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Cell": {
                    "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#219FD7",
                          "Expression": "{stefan - percentage werkzaamheden overschreden} = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#8B5011",
                          "Expression": "COUNT({Stefan - taak te laat uitgevoerd}) = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#8B5011",
                          "Expression": "COUNT({Stefan - taak te vroeg begonnen}) = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#FF8700",
                          "Expression": "DISTINCT_COUNT({Stefan - Traveltime exceeded geef id terug wegen dubble id}) = 1"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#F7E65A",
                          "Expression": "DISTINCT_COUNT({Stefan - Traveltime exceeded geef id terug wegen dubble id}) = 0"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "Visibility": "HIDDEN"
            },
            "VisualId": "081274a4-be60-44eb-8054-f4aa26347b52"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "aaa73d4e-37b2-46a6-8896-f205782c7514",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064588032",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "245px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.1.1697097889565",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064588032",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.1.1697097889565",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": "%"
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.1.1697097889565"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#A8577B",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#8B5011",
                  "FontConfiguration": {
                    "FontColor": "#EEEEEE"
                  },
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitgevoerd volgens rooster % per medewerker</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "01f47ef0-4de0-4951-aabb-1a9d06de6487"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "66e6549e-f90a-4ad1-aa9a-d54e31ad0260",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064579703",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "237px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1698694155139",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "109px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064579703",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "Stefan - Traveltime exceeded geef id terug wegen dubble id",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1698694155139"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1698694155139"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#FF8700",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 20
                },
                "HeaderStyle": {
                  "BackgroundColor": "#FF8700",
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal aanrijtijden overschreden per medewerker</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "f12ec4eb-7f6a-4924-b96e-0442be0c89a9"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "3ca00efd-1b66-4541-b739-5394b5634bc4",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "ScrollbarOptions": {
                  "Visibility": "VISIBLE",
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 39.617414248021106,
                      "To": 92.12401055408971
                    }
                  }
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1696490853326",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Position": "RIGHT",
                "Width": "152px"
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.alarmtype.1.1696490853326",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "AxisOffset": "78px",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen per activiteit en alarmtype</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "35f3f904-5896-4cd7-8a0a-5655ece43c14"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "traveltime exceeded",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.0.1680598668400"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal overschreden aanrijtijden</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "8b356834-5526-4dea-80d4-8c27e82d3a2e"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "bcdf4acf-1b2e-491a-907a-1ef263c9736c",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064573768",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "32a95a69-0938-4848-9ea2-3ac82f6aa712.2.1698778013133",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064573768",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "avg traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "32a95a69-0938-4848-9ea2-3ac82f6aa712.2.1698778013133"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "32a95a69-0938-4848-9ea2-3ac82f6aa712.2.1698778013133"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#F7E65A",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 24
                },
                "HeaderStyle": {
                  "BackgroundColor": "#F7E65A",
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              },
              "TotalOptions": {
                "Placement": "END",
                "TotalsVisibility": "HIDDEN"
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddelde aanrijdtijden per medewerker</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "29f66f38-c7dd-40fa-a631-d98ecd66d9ac"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "29304c01-699c-46c5-8461-01d66233cf90",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "STACKED",
              "CategoryAxis": {
                "AxisLineVisibility": "HIDDEN",
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MONTH",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718",
                        "FormatConfiguration": null,
                        "HierarchyId": "37f6cd89-5876-4aff-be0d-423173358175"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696438800883"
                      }
                    }
                  ]
                }
              },
              "Orientation": "VERTICAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696438800883",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "37f6cd89-5876-4aff-be0d-423173358175"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen over tijd (per maand)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "a49845d6-e333-4267-95d4-285e770d9f18"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "26e0aee0-3cda-4bf1-aab1-561285e7e94c",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064558723",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "232px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1696421410096",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "61px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064558723",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1696421410096"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1696421410096"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#1E1217",
                      "Style": "SOLID",
                      "Thickness": 2
                    }
                  },
                  "FontConfiguration": {},
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#000000",
                  "FontConfiguration": {
                    "FontColor": "#EEEEEE"
                  },
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen per medewerker</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "3771c0ca-c05e-4f7c-a073-70769798f341"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "69c30945-e668-4aff-9ac2-d41f0b529aab",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "ScrollbarOptions": {
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 46.17414248021109,
                      "To": 100
                    }
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.1.1696488812710",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                      }
                    }
                  ]
                }
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.1.1696488812710",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696421574379",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "AxisOffset": "129px",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen per product</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "757ef040-1601-4861-9a42-4bd37304b628"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "AVERAGE"
                      },
                      "Column": {
                        "ColumnName": "traveltime",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.1.1696438556802"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "TooltipVisibility": "HIDDEN",
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Gemiddelde aanrijtijd (min)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "06775790-5aed-445a-bc76-309219a4582e"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "a6a1f427-48d8-4b6c-8823-611d89ad7d5d",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "taskstate",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskstate.1.1696493774641",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696493783609"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                }
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696493783609"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskstate.1.1696493774641",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1696493783609",
                        "Label": "Opdrachten",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Status taken</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5fb9eb68-c0b1-4cdb-b059-c6c7e92f8618"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - percentage werkzaamheden overschreden",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.0.1697097435852",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "SeparatorConfiguration": {
                              "DecimalSeparator": "DOT",
                              "ThousandsSeparator": {
                                "Symbol": "COMMA",
                                "Visibility": "VISIBLE"
                              }
                            },
                            "Suffix": "%"
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitvoering binnen Tijdslimit %</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "ca222eca-883b-46ab-82de-27dd0055ce2f"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - percentage begonnen task buiten geplande tijd",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.0.1697097571064",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "SeparatorConfiguration": {
                              "DecimalSeparator": "DOT",
                              "ThousandsSeparator": {
                                "Symbol": "COMMA",
                                "Visibility": "VISIBLE"
                              }
                            },
                            "Suffix": "%"
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitgevoerd volgens rooster %</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "f1a12147-baa7-43af-ab25-1fd5697a1804"
          }
        },
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "fd91a63e-ea41-4cc0-8e11-b5973aeb2d7e",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064584424",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "223px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.1.1697097761498",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "61px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.1.1700064584424",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan - percentage werkzaamheden overschreden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.1.1697097761498",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": "%"
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.1.1697097761498"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Color": "#219FD7",
                      "Style": "SOLID"
                    }
                  },
                  "Height": 25
                },
                "HeaderStyle": {
                  "BackgroundColor": "#219FD7",
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitvoering binnen Tijdslimit % per medewerker</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "a5b3e433-742e-418d-a55b-1141efd517af"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "DISTINCT_COUNT"
                      },
                      "Column": {
                        "ColumnName": "taskid",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.0.1697183037772"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "PERCENT_DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Sparkline": {
                  "Type": "AREA",
                  "Visibility": "VISIBLE"
                },
                "VisualLayoutOptions": {
                  "StandardLayout": {
                    "Type": "VERTICAL"
                  }
                }
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal opvolgingen</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5bfafc2d-1782-4205-860b-298cf0413e0c"
          }
        },
        {
          "TableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": null,
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftid.0.1700074756543",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "109px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftid.0.1700074756543",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.5.1700075579687",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualstarted",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.1.1700074786034",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftstarted",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftstarted.2.1700074788354",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.3.1700074795666",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftended.4.1700074855111",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "workshiftactualstarted_telaat_avg",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "dde02fd3-c058-4072-8aee-cf59aebf7bc4.6.1700076515392"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftstarted.2.1700074788354"
                    }
                  }
                ]
              },
              "TableOptions": {
                "HeaderStyle": {
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Tabel met diensten</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "f58553a1-52db-4124-a2f4-02d0f3fdb2b7"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "820eaa0d-6607-442f-932e-fe5e3da03a3c",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 16,
                  "ElementId": "bdd87f19-9c70-4d29-a079-2ed2c44555e8",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 22,
                  "ColumnSpan": 14,
                  "ElementId": "37c85845-07fc-47c8-92c3-13905206b2c2",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 12
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "6a804d9a-d642-4122-aeca-7ded75898ad5",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "92addb14-aec8-422f-8958-24a7fc2669aa",
                  "ElementType": "VISUAL",
                  "RowIndex": 6,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 16,
                  "ElementId": "bd11c048-473c-4445-8259-3ad622f64312",
                  "ElementType": "VISUAL",
                  "RowIndex": 6,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "f822d594-e0d5-41a1-bacf-c5d6899544e4",
                  "ElementType": "VISUAL",
                  "RowIndex": 9,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 9,
                  "ElementId": "b46901af-1417-478a-924b-c2ab8c51d88f",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 9,
                  "ColumnSpan": 9,
                  "ElementId": "5e9c3845-0a51-4e8f-b8d5-f67ff094736c",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 9,
                  "ElementId": "ba733caf-36ea-45f2-b643-ec9b8a96328b",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 27,
                  "ColumnSpan": 9,
                  "ElementId": "d97ebb91-ebce-4aba-b449-8e1f0272fabb",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "082fe431-240b-4d37-9173-416277acd274",
                  "ElementType": "VISUAL",
                  "RowIndex": 18,
                  "RowSpan": 7
                }
              ]
            }
          }
        }
      ],
      "Name": "Aanrijtijden",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "89301262-9f8e-401a-83c5-210ef0890664",
            "SourceParameterName": "start",
            "Title": "Vanaf"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "2479a67e-9b11-4a73-bcf4-73e6c67d6cad",
            "SourceParameterName": "end",
            "Title": "Tot"
          }
        },
        {
          "Dropdown": {
            "CascadingControlConfiguration": {
              "SourceControls": [
                {
                  "ColumnToMatch": {
                    "ColumnName": "alarmtype",
                    "DataSetIdentifier": "sequrix_tasks_records"
                  },
                  "SourceSheetControlId": "6609ac03-1783-4c42-9ca9-ac5dd515815d"
                },
                {
                  "ColumnToMatch": {
                    "ColumnName": "alarmtype prio",
                    "DataSetIdentifier": "sequrix_tasks_records"
                  },
                  "SourceSheetControlId": "76473f29-1bac-48b6-94ae-b020980e75ca"
                }
              ]
            },
            "DisplayOptions": {
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "c7bed0c5-e87e-48d2-bb12-38e1f386c483",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "productname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "productname",
            "Title": "Type",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "CascadingControlConfiguration": {
              "SourceControls": [
                {
                  "ColumnToMatch": {
                    "ColumnName": "productname",
                    "DataSetIdentifier": "sequrix_tasks_records"
                  },
                  "SourceSheetControlId": "c7bed0c5-e87e-48d2-bb12-38e1f386c483"
                },
                {
                  "ColumnToMatch": {
                    "ColumnName": "alarmtype prio",
                    "DataSetIdentifier": "sequrix_tasks_records"
                  },
                  "SourceSheetControlId": "76473f29-1bac-48b6-94ae-b020980e75ca"
                }
              ]
            },
            "DisplayOptions": {
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "6609ac03-1783-4c42-9ca9-ac5dd515815d",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmtype",
            "Title": "Alarm type",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "CascadingControlConfiguration": {
              "SourceControls": [
                {
                  "ColumnToMatch": {
                    "ColumnName": "productname",
                    "DataSetIdentifier": "sequrix_tasks_records"
                  },
                  "SourceSheetControlId": "c7bed0c5-e87e-48d2-bb12-38e1f386c483"
                },
                {
                  "ColumnToMatch": {
                    "ColumnName": "alarmtype",
                    "DataSetIdentifier": "sequrix_tasks_records"
                  },
                  "SourceSheetControlId": "6609ac03-1783-4c42-9ca9-ac5dd515815d"
                }
              ]
            },
            "DisplayOptions": {
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "76473f29-1bac-48b6-94ae-b020980e75ca",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype prio",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmprio",
            "Title": "Alarm prio",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "89301262-9f8e-401a-83c5-210ef0890664",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "2479a67e-9b11-4a73-bcf4-73e6c67d6cad",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "c7bed0c5-e87e-48d2-bb12-38e1f386c483",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "76473f29-1bac-48b6-94ae-b020980e75ca",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "6609ac03-1783-4c42-9ca9-ac5dd515815d",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "65ea2e97-2395-4429-84d7-cc31ec375d44",
      "Visuals": [
        {
          "LineChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFields": [
                          "5e7cb65e-9134-4560-9a41-87361723e77e.2.1644236315463"
                        ]
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "379c6dbc-172b-49dd-8302-4d703e6bdff6",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "LineChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "WEEK",
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1640094128779",
                        "FormatConfiguration": null,
                        "HierarchyId": "da08c973-68f9-49f9-85af-889ab6f21b74"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype prio",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.2.1644236315463",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "AVERAGE"
                        },
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1640093220940"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "CustomLabel": "Prio",
                  "Visibility": "HIDDEN"
                },
                "Width": "100px"
              },
              "PrimaryYAxisLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimitConfiguration": {
                  "ItemsLimit": 400,
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1640094128779"
                    }
                  }
                ],
                "ColorItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1640093220940",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1640094128779",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.2.1644236315463",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "Type": "LINE",
              "XAxisLabelOptions": {
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "da08c973-68f9-49f9-85af-889ab6f21b74"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"14px\">Aanrijtijd (Trend afgelopen 3 maanden)</inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "bd11c048-473c-4445-8259-3ad622f64312"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "AVERAGE"
                      },
                      "Column": {
                        "ColumnName": "traveltime",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1680599037355",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "NumberDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            }
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Prio 2 gem. aanrijtijd</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "f822d594-e0d5-41a1-bacf-c5d6899544e4"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "AVERAGE"
                      },
                      "Column": {
                        "ColumnName": "traveltime",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1680599037355",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "NumberDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            }
                          }
                        }
                      }
                    }
                  }
                ]
              },
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Prio 1 gem. aanrijtijd</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "92addb14-aec8-422f-8958-24a7fc2669aa"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "ended",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "DateGranularity": "DAY",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1680598703835",
                      "FormatConfiguration": null,
                      "HierarchyId": "355bb049-d09e-447b-812a-dcf70bc4e5f5"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "traveltime exceeded",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.0.1680598668400"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1680598703835"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "355bb049-d09e-447b-812a-dcf70bc4e5f5"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "SUM({traveltime exceeded}) > 0"
                      }
                    }
                  }
                },
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "SUM({traveltime exceeded}) = 0"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Prio 2 aanrijtijd overschreden</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "6a804d9a-d642-4122-aeca-7ded75898ad5"
          }
        },
        {
          "TableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Start",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.started.7.1640094169415",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Eind",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.6.1640094141148",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Object",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.objectname.8.1642515390084",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "148px"
                  },
                  {
                    "CustomLabel": "Aanrijtijd",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1640090451232",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "86px"
                  },
                  {
                    "CustomLabel": "Max. aanrijtijd",
                    "FieldId": "f6096ff7-6967-41bd-a515-db480de2aa46.7.1641385367247",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "106px"
                  },
                  {
                    "CustomLabel": "Type",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.productname.5.1640093835984",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": null,
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.alarmtype.8.1644236452061",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "184px"
                  },
                  {
                    "CustomLabel": "Reden",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltimeexceededcause.2.1640090484837",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "213px"
                  },
                  {
                    "CustomLabel": "Extra commentaar",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.externalcomment.4.1640091092290",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "635px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.9.1694191048091",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.started.7.1640094169415",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.6.1640094141148",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "taskstate",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskstate.10.1694690807666",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.objectname.8.1642515390084",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1640090451232",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "maxtraveltime (with default)",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "f6096ff7-6967-41bd-a515-db480de2aa46.7.1641385367247",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.productname.5.1640093835984",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.alarmtype.8.1644236452061",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "traveltimeexceededcause",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltimeexceededcause.2.1640090484837",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "externalcomment",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.externalcomment.4.1640091092290",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": []
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.started.7.1640094169415"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "HorizontalTextAlignment": "LEFT",
                  "TextWrap": "WRAP"
                },
                "HeaderStyle": {
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Aanrijtijd overschreden"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "082fe431-240b-4d37-9173-416277acd274"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "d659cf06-047e-43b0-928b-eec82e7c8ee9",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.0.1640091268722",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1640091273771"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Width": "152px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1640091273771"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.0.1640091268722",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1640091273771",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Taken per regio"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "ba733caf-36ea-45f2-b643-ec9b8a96328b"
          }
        },
        {
          "LineChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFields": [
                          "5e7cb65e-9134-4560-9a41-87361723e77e.2.1644236315463"
                        ]
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "114e1054-dcda-49be-b013-bbd6b397c9df",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "LineChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1640094128779",
                        "FormatConfiguration": null,
                        "HierarchyId": "e3121a17-3b38-4e61-a5a3-5416e18f872d"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype prio",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.2.1644236315463",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "AVERAGE"
                        },
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1640093220940"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "CustomLabel": "Prio",
                  "Visibility": "HIDDEN"
                },
                "Width": "100px"
              },
              "PrimaryYAxisDisplayOptions": {
                "MissingDataConfigurations": [
                  {
                    "TreatmentOption": "SHOW_AS_ZERO"
                  }
                ]
              },
              "PrimaryYAxisLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimitConfiguration": {
                  "ItemsLimit": 400,
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1640094128779"
                    }
                  }
                ],
                "ColorItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1640093220940",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1640094128779",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.2.1644236315463",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "Type": "LINE",
              "XAxisLabelOptions": {
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "e3121a17-3b38-4e61-a5a3-5416e18f872d"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"14px\">Aanrijtijd (per minuut)</inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "bdd87f19-9c70-4d29-a079-2ed2c44555e8"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "a49125b0-2fd0-455a-945d-2d843f42d83f",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "customername",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.customername.0.1640093275977",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1640093279031"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Width": "169px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "ItemsLimit": 40,
                  "OtherCategories": "EXCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1640093279031"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "EXCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.customername.0.1640093275977",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.1.1640093279031",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Taken per klant"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "d97ebb91-ebce-4aba-b449-8e1f0272fabb"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "87245088-8971-433e-9611-71f430a8a8f9",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype prio",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.1.1644236632234",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.0.1644236626331"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "CustomLabel": "Prio",
                  "Visibility": "HIDDEN"
                },
                "Width": "137px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.1.1644236632234"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.0.1644236626331",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.1.1644236632234",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Alarm per prio</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5e9c3845-0a51-4e8f-b8d5-f67ff094736c"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "e5b6f68f-e16f-4ec7-911f-41ba0829d357",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.alarmtype.1.1644236781273",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.0.1644236762374"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "CustomLabel": "Type",
                  "Visibility": "HIDDEN"
                },
                "Width": "139px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.0.1644236762374"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.taskid.0.1644236762374",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.alarmtype.1.1644236781273",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Alarm per type</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "b46901af-1417-478a-924b-c2ab8c51d88f"
          }
        },
        {
          "PivotTableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "25498e4b-5569-4cbd-b3d7-dad80b555b13",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "DataPathOptions": [
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.3.1680598296493",
                        "FieldValue": "regionname"
                      }
                    ],
                    "Width": "206px"
                  },
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.2.1680598232050",
                        "FieldValue": "traveltime exceeded"
                      }
                    ],
                    "Width": "152px"
                  },
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1680598226044",
                        "FieldValue": "traveltime"
                      }
                    ],
                    "Width": "139px"
                  },
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.3.1680598245687",
                        "FieldValue": "alarmtype prio"
                      }
                    ],
                    "Width": "124px"
                  }
                ],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Prio",
                    "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.3.1680598245687",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Regio",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.3.1680598296493",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Gem. Aanrijtijd [m]",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1680598226044",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Aanrijtijd overschreden",
                    "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.2.1680598232050",
                    "Visibility": "VISIBLE"
                  }
                ]
              },
              "FieldWells": {
                "PivotTableAggregatedFieldWells": {
                  "Columns": [],
                  "Rows": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "alarmtype prio",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "5e7cb65e-9134-4560-9a41-87361723e77e.3.1680598245687",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.regionname.3.1680598296493",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "AVERAGE"
                        },
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.traveltime.1.1680598226044"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "traveltime exceeded",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.2.1680598232050"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "FieldSortOptions": []
              },
              "TableOptions": {
                "CellStyle": {
                  "TextWrap": "NONE"
                },
                "CollapsedRowDimensionsVisibility": "HIDDEN",
                "ColumnHeaderStyle": {
                  "Height": 63,
                  "TextWrap": "WRAP"
                }
              },
              "TotalOptions": {
                "ColumnTotalOptions": {
                  "TotalsVisibility": "HIDDEN"
                },
                "RowSubtotalOptions": {
                  "StyleTargets": [
                    {
                      "CellType": "TOTAL"
                    }
                  ],
                  "TotalCellStyle": {},
                  "TotalsVisibility": "HIDDEN"
                },
                "RowTotalOptions": {
                  "TotalsVisibility": "HIDDEN"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  Aanrijtijden per regio (\n  <parameter>$${start}</parameter>\n   tot \n  <parameter>$${end}</parameter>\n  )\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "37c85845-07fc-47c8-92c3-13905206b2c2"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "ended",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1680598703835",
                      "FormatConfiguration": null,
                      "HierarchyId": "0b84dd23-5ac4-450f-933b-6ddf110add77"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "SUM"
                      },
                      "Column": {
                        "ColumnName": "traveltime exceeded",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "d57c607e-bede-4b0a-9be0-405f9e8369f8.0.1680598668400"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.ended.1.1680598703835"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "0b84dd23-5ac4-450f-933b-6ddf110add77"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "SUM({traveltime exceeded}) > 0"
                      }
                    }
                  }
                },
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "SUM({traveltime exceeded}) = 0"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Prio 1 aanrijtijd overschreden</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "820eaa0d-6607-442f-932e-fe5e3da03a3c"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "FilterControls": [
        {
          "Dropdown": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "bdd6f51e-e845-4068-a9f3-f9ed62cd9515",
            "SourceFilterId": "2e9a1b30-a89b-43a6-b300-03e0dcd667a8",
            "Title": "Type",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 9,
                  "ElementId": "09204ae0-6632-4dc7-b679-433b669045e4",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 9,
                  "ColumnSpan": 9,
                  "ElementId": "86f2845d-e3dd-44ef-b8ac-cabd0fda5166",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 9,
                  "ElementId": "ce1ca375-3c2f-464a-ac8b-1fa7c29dfb6c",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 27,
                  "ColumnSpan": 9,
                  "ElementId": "73b15c09-2d43-4edb-991b-8cc86e2d9816",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 18,
                  "ElementId": "5a08de57-e84d-46c5-ae29-523b5875296b",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 9
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 18,
                  "ElementId": "4d1c4489-723c-41fd-8fbc-b52bb8b284bd",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 9
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 18,
                  "ElementId": "6c3a77db-be4b-4eb9-99cb-8f381372023d",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 10
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 18,
                  "ElementId": "521253b7-389d-4c6a-82b4-6ae34563d93f",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 10
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "cda3ade0-5a49-4172-b5e3-e211097f60ca",
                  "ElementType": "VISUAL",
                  "RowIndex": 22,
                  "RowSpan": 10
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "8b721252-f974-454e-bd79-0e4fb4c856ff",
                  "ElementType": "VISUAL",
                  "RowIndex": 32,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "04195131-da64-4dd9-9a8d-eb7d585628ef",
                  "ElementType": "VISUAL",
                  "RowIndex": 40,
                  "RowSpan": 10
                }
              ]
            }
          }
        }
      ],
      "Name": "Barcodes",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "2d78e810-75f7-4b61-9439-11f21b22c7f2",
            "SourceParameterName": "start",
            "Title": "Vanaf"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "90fa19c6-84e6-4244-a3fe-8fbbb175d35e",
            "SourceParameterName": "end",
            "Title": "Tot"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "22b0567c-0107-4955-b7eb-96a6cf23037f",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "employee",
                "DataSetIdentifier": "sequrix_planning_records"
              }
            },
            "SourceParameterName": "employee",
            "Title": "Medewerker",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "DisplayOptions": {
              "SelectAllOptions": {
                "Visibility": "VISIBLE"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "e3bdc7e2-736d-4a9a-9eb6-83b31b54b4d4",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "objectname",
                "DataSetIdentifier": "sequrix_planning_records"
              }
            },
            "SourceParameterName": "object",
            "Title": "Object",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "2d78e810-75f7-4b61-9439-11f21b22c7f2",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "90fa19c6-84e6-4244-a3fe-8fbbb175d35e",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "22b0567c-0107-4955-b7eb-96a6cf23037f",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "e3bdc7e2-736d-4a9a-9eb6-83b31b54b4d4",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": null,
                  "ColumnSpan": 2,
                  "ElementId": "bdd6f51e-e845-4068-a9f3-f9ed62cd9515",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": null,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "9d75aef0-5a3a-4d06-9743-dcc8bdf3956c",
      "Visuals": [
        {
          "PivotTableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "DataPathOptions": [
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.6.1640096462483",
                        "FieldValue": "comment"
                      }
                    ],
                    "Width": "518px"
                  },
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.2.1640096414428",
                        "FieldValue": "location"
                      }
                    ],
                    "Width": "290px"
                  },
                  {
                    "DataPathList": [
                      {
                        "DataPathType": null,
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.7.1641387406518",
                        "FieldValue": "objectname"
                      }
                    ],
                    "Width": "254px"
                  }
                ],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Dag",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.6.1640595569651",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Object",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.7.1641387406518",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Locatie",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.2.1640096414428",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Taak",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.taskid.1.1640096407273",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Type",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.checkpointtypeenumname.7.1640096471641",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Afstand",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.4.1640096446977",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Commentaar",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.6.1640096462483",
                    "Visibility": "VISIBLE"
                  }
                ]
              },
              "FieldWells": {
                "PivotTableAggregatedFieldWells": {
                  "Columns": [],
                  "Rows": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "scanneddatetime",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "DateGranularity": null,
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.6.1640595569651",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.7.1641387406518",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "location",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.2.1640096414428",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.taskid.1.1640096407273",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "checkpointtypeenumname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.checkpointtypeenumname.7.1640096471641",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "distancetocheckpointlocation",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.4.1640096446977",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "comment",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.6.1640096462483",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": []
                }
              },
              "SortConfiguration": {
                "FieldSortOptions": [
                  {
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.6.1640595569651",
                    "SortBy": {
                      "Field": {
                        "Direction": "DESC",
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.6.1640595569651"
                      }
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "TextWrap": "NONE"
                },
                "ColumnHeaderStyle": {
                  "TextWrap": "NONE"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Scan overzicht"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "04195131-da64-4dd9-9a8d-eb7d585628ef"
          }
        },
        {
          "TableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "SequriX",
                    "FieldId": "7d0b5775-e1f2-4c54-b592-dfeef4a40fee.11.1643201717786",
                    "URLStyling": {
                      "ImageConfiguration": null,
                      "LinkConfiguration": {
                        "Content": {
                          "CustomIconContent": null,
                          "CustomTextContent": {
                            "FontConfiguration": {
                              "FontColor": null,
                              "FontDecoration": "UNDERLINE",
                              "FontSize": null,
                              "FontStyle": null,
                              "FontWeight": null
                            },
                            "Value": "Details"
                          }
                        },
                        "Target": "NEW_TAB"
                      }
                    },
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Dag",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.9.1640595447873",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Taak",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.taskid.1.1640096407273",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "PlanningId",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.3.1640096426224",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "91px"
                  },
                  {
                    "CustomLabel": "Object",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.10.1641387397680",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "247px"
                  },
                  {
                    "CustomLabel": "Locatie",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.2.1640096414428",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "291px"
                  },
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.5.1640096456955",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "156px"
                  },
                  {
                    "CustomLabel": "Type",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.checkpointtypeenumname.7.1640096471641",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Afstand",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.4.1640096446977",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "65px"
                  },
                  {
                    "CustomLabel": "Commentaar",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.6.1640096462483",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "342px"
                  },
                  {
                    "CustomLabel": "# handmatig gescand",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.8.1640096605058",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "taskLink",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "7d0b5775-e1f2-4c54-b592-dfeef4a40fee.11.1643201717786",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "scanneddatetime",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "DateGranularity": null,
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.9.1640595447873",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.taskid.1.1640096407273",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "planningresultcheckpointid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.3.1640096426224",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.10.1641387397680",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "location",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.2.1640096414428",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.5.1640096456955",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "checkpointtypeenumname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.checkpointtypeenumname.7.1640096471641",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "distancetocheckpointlocation",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.4.1640096446977",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "comment",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.6.1640096462483",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "manuallyscanned",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.8.1640096605058"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.9.1640595447873"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Height": 25
                },
                "HeaderStyle": {
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Handmatig en niet gescande barcodes"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "cda3ade0-5a49-4172-b5e3-e211097f60ca"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "scanneddatetime",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096521796",
                      "FormatConfiguration": null,
                      "HierarchyId": "676be224-971e-4dcc-9417-8ca299c190d8"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "COUNT"
                      },
                      "Column": {
                        "ColumnName": "planningresultcheckpointid",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.0.1640096490651"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096521796"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "676be224-971e-4dcc-9417-8ca299c190d8"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "difference(COUNT({planningresultcheckpointid}),[COUNT({planningresultcheckpointid}) DESC],1,[]) < 0"
                      }
                    }
                  }
                },
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "difference(COUNT({planningresultcheckpointid}),[COUNT({planningresultcheckpointid}) DESC],1,[]) > 0"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Barcodes scanned"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "09204ae0-6632-4dc7-b679-433b669045e4"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "scanneddatetime",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096640311",
                      "FormatConfiguration": null,
                      "HierarchyId": "9e141e5e-9600-4b91-b8d1-8f3e9f10546b"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "COUNT"
                      },
                      "Column": {
                        "ColumnName": "planningresultcheckpointid",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.0.1640096580746"
                    }
                  }
                ]
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096640311"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "9e141e5e-9600-4b91-b8d1-8f3e9f10546b"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "difference(COUNT({planningresultcheckpointid}),[COUNT({planningresultcheckpointid}) DESC],1,[]) < 0"
                      }
                    }
                  }
                },
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "difference(COUNT({planningresultcheckpointid}),[COUNT({planningresultcheckpointid}) DESC],1,[]) > 0"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Handmatig gescanned"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "86f2845d-e3dd-44ef-b8ac-cabd0fda5166"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "c82628a8-91fb-497c-94cd-9d81d983dd23",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "ScrollbarOptions": {
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 64.28571428571438,
                      "To": 100
                    }
                  }
                }
              },
              "CategoryLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.0.1640096672199",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "COUNT"
                        },
                        "Column": {
                          "ColumnName": "planningresultcheckpointid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.1.1640096674733"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "scanerror",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "96e006ed-7387-4bc9-9938-92fff13369cb.2.1643203208868"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Visibility": "HIDDEN"
              },
              "Orientation": "HORIZONTAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "96e006ed-7387-4bc9-9938-92fff13369cb.2.1643203208868"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.0.1640096672199",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.1.1640096674733",
                        "Label": "Totaal",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "96e006ed-7387-4bc9-9938-92fff13369cb.2.1643203208868",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Barcodes gescand (Handmatig/error vs Totaal)"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5a08de57-e84d-46c5-ae29-523b5875296b"
          }
        },
        {
          "LineChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "LineChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "scanneddatetime",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "DateGranularity": "HOUR",
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096696945",
                        "FormatConfiguration": null,
                        "HierarchyId": "b9c1ec0b-8202-4f0c-8380-f553d540f1a9"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "COUNT"
                        },
                        "Column": {
                          "ColumnName": "planningresultcheckpointid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.0.1640096695329",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT"
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "PrimaryYAxisLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096696945"
                    }
                  }
                ],
                "ColorItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.0.1640096695329",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096696945",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "Type": "LINE",
              "XAxisDisplayOptions": {
                "ScrollbarOptions": {
                  "VisibleRange": {
                    "PercentRange": {
                      "From": 0,
                      "To": 100
                    }
                  }
                }
              },
              "XAxisLabelOptions": {
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "b9c1ec0b-8202-4f0c-8380-f553d540f1a9"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Barcodes gescand per dag"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "6c3a77db-be4b-4eb9-99cb-8f381372023d"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "scanneddatetime",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096742092",
                      "FormatConfiguration": null,
                      "HierarchyId": "96ce6bd3-c324-4547-b51d-7e3a5eae2cb3"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "CategoricalMeasureField": {
                      "AggregationFunction": "DISTINCT_COUNT",
                      "Column": {
                        "ColumnName": "employee",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.0.1640096730752"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640096742092"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "96ce6bd3-c324-4547-b51d-7e3a5eae2cb3"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Medewerkers die gescand hebben"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "ce1ca375-3c2f-464a-ac8b-1fa7c29dfb6c"
          }
        },
        {
          "KPIVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldWells": {
                "TargetValues": [],
                "TrendGroups": [
                  {
                    "CategoricalDimensionField": null,
                    "DateDimensionField": {
                      "Column": {
                        "ColumnName": "scanneddatetime",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "DateGranularity": null,
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640097067059",
                      "FormatConfiguration": null,
                      "HierarchyId": "47cf32eb-a3de-4fbb-b271-c46898906481"
                    },
                    "NumericalDimensionField": null
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "AggregationFunction": {
                        "SimpleNumericalAggregation": "AVERAGE"
                      },
                      "Column": {
                        "ColumnName": "distancetocheckpointlocation",
                        "DataSetIdentifier": "sequrix_planning_records"
                      },
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.0.1640097043310"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "PrimaryValueDisplayType": "ACTUAL"
              },
              "SortConfiguration": {
                "TrendGroupSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640097067059"
                    }
                  }
                ]
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "47cf32eb-a3de-4fbb-b271-c46898906481"
                }
              }
            ],
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "difference(AVG({distancetocheckpointlocation}),[AVG({distancetocheckpointlocation}) DESC],1,[]) < 0"
                      }
                    }
                  }
                },
                {
                  "PrimaryValue": {
                    "TextColor": {
                      "Solid": {
                        "Color": "#DE3B00",
                        "Expression": "difference(AVG({distancetocheckpointlocation}),[AVG({distancetocheckpointlocation}) DESC],1,[]) > 0"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Gem. afstand tot checkpoint"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "73b15c09-2d43-4edb-991b-8cc86e2d9816"
          }
        },
        {
          "LineChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "LineChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "scanneddatetime",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "DateGranularity": "HOUR",
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640598259542",
                        "FormatConfiguration": null,
                        "HierarchyId": "6ae68045-04f5-4acc-9cb8-a999ac702460"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "AVERAGE"
                        },
                        "Column": {
                          "ColumnName": "distancetocheckpointlocation",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.0.1640598257367"
                      }
                    }
                  ]
                }
              },
              "PrimaryYAxisLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640598259542"
                    }
                  }
                ],
                "ColorItemsLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.0.1640598257367",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.1.1640598259542",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "Type": "LINE",
              "XAxisLabelOptions": {
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "6ae68045-04f5-4acc-9cb8-a999ac702460"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Gemiddelde afstand tot scan locatie"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "521253b7-389d-4c6a-82b4-6ae34563d93f"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "fe39b7b1-dce6-48fb-ae13-6d7b2203ea5c",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.0.1641390983698",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "manuallyscanned",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.1.1641390990706"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "VISIBLE",
                "Width": "212px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "EXCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.1.1641390990706"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "EXCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.0.1641390983698",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.manuallyscanned.1.1641390990706",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "DETAILED",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Handmatig gescand per object"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "4d1c4489-723c-41fd-8fbc-b52bb8b284bd"
          }
        },
        {
          "TableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "Order": [],
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Dag",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.0.1641422036182",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Taak",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.taskid.1.1641422039904",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "PlanningId",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.2.1641422049518",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Object",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.3.1641422052830",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "308px"
                  },
                  {
                    "CustomLabel": "Locatie",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.4.1641422058539",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.5.1641422068680",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  },
                  {
                    "CustomLabel": null,
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.7.1641422224893",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": "289px"
                  },
                  {
                    "CustomLabel": "Afstand",
                    "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.6.1641422073559",
                    "URLStyling": null,
                    "Visibility": null,
                    "Width": null
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "scanneddatetime",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "DateGranularity": null,
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.0.1641422036182",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.taskid.1.1641422039904",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": null,
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "planningresultcheckpointid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.planningresultcheckpointid.2.1641422049518",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.objectname.3.1641422052830",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "location",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.location.4.1641422058539",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.employee.5.1641422068680",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "comment",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.comment.7.1641422224893",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "AVERAGE"
                        },
                        "Column": {
                          "ColumnName": "distancetocheckpointlocation",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.distancetocheckpointlocation.6.1641422073559"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "e9bf7bdd-11f3-4508-bf20-d9da9231b0f2.scanneddatetime.0.1641422036182"
                    }
                  }
                ]
              },
              "TableOptions": {
                "HeaderStyle": {
                  "Height": 25,
                  "TextWrap": "WRAP"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "PlainText": "Afstand tot scan locatie > 1km"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "8b721252-f974-454e-bd79-0e4fb4c856ff"
          }
        }
      ]
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "ResizeOption": "RESPONSIVE"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 12,
                  "ElementId": "e631fa47-b926-4b55-ad15-1eb2b93de783",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 12,
                  "ElementId": "24381326-615b-4736-8072-d41abaf2e0b5",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 24,
                  "ColumnSpan": 12,
                  "ElementId": "5b91633a-99ed-4dbd-9f24-2a25906fd84b",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 17,
                  "ElementId": "73001c5f-a33e-471a-98a4-acc57015733e",
                  "ElementType": "VISUAL",
                  "RowIndex": 7,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 17,
                  "ColumnSpan": 19,
                  "ElementId": "2a1d46bf-7951-42ce-a3ff-d4e01e67e135",
                  "ElementType": "VISUAL",
                  "RowIndex": 7,
                  "RowSpan": 7
                }
              ]
            }
          }
        }
      ],
      "Name": "TEST - Alarmen",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "a748cb0b-ab9e-4a92-b769-d0c7d1d48db8",
            "SourceParameterName": "start",
            "Title": "Start"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD HH:mm:ss",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "20524e42-77a7-4dd1-85f3-dcdc1bacf5e4",
            "SourceParameterName": "end",
            "Title": "End"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": null,
              "Elements": [
                {
                  "ColumnIndex": null,
                  "ColumnSpan": 2,
                  "ElementId": "a748cb0b-ab9e-4a92-b769-d0c7d1d48db8",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": null,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": null,
                  "ColumnSpan": 2,
                  "ElementId": "20524e42-77a7-4dd1-85f3-dcdc1bacf5e4",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": null,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "3a5fec6e-39a8-4e43-a596-00879307ae6d",
      "Visuals": [
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "61c82bc4-c4f5-4cfb-ab4b-9fa2cbedfc6b",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "CategoryLabelVisibility": "VISIBLE",
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "MeasureLabelVisibility": "HIDDEN",
                "Overlap": "DISABLE_OVERLAP",
                "Position": "OUTSIDE",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "WHOLE"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "Stefan -workshift(avond/dag/nacht)",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "4270795c-6b71-44f5-b98c-bcfcdbe488da.1.1694606073275",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694615362062"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "100px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694615362062"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "4270795c-6b71-44f5-b98c-bcfcdbe488da.1.1694606073275",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694615362062",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Workshift(dag/avond/nacht)</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "24381326-615b-4736-8072-d41abaf2e0b5"
          }
        },
        {
          "HeatMapVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "277f9382-6e5b-4d3c-9442-8f288d39a58e",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "ColorScale": {
                "ColorFillType": "GRADIENT",
                "Colors": [
                  {
                    "Color": "#2CAD00"
                  },
                  {
                    "Color": "#DE3B00"
                  }
                ],
                "NullValueColor": {
                  "Color": "#A7DBE2"
                }
              },
              "ColumnLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "HeatMapAggregatedFieldWells": {
                  "Columns": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "Stefan started(hour of the day)",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e8301dc5-c08a-4c0a-9249-2b76f6122857.2.1694435335309",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Rows": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "stefan - started(day of the week",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c979efe5-8fef-490c-adf8-42be1e520435.2.1694440460450",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1694611424594"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "VISIBLE",
                "Width": "100px"
              },
              "RowLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "HeatMapColumnSort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "e8301dc5-c08a-4c0a-9249-2b76f6122857.2.1694435335309"
                    }
                  }
                ]
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e8301dc5-c08a-4c0a-9249-2b76f6122857.2.1694435335309",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "c979efe5-8fef-490c-adf8-42be1e520435.2.1694440460450",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1694611424594",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal alarmen verdeeld op uren van de week</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "2a1d46bf-7951-42ce-a3ff-d4e01e67e135"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "FilterOperation": {
                      "SelectedFieldsConfiguration": {
                        "SelectedFieldOptions": "ALL_FIELDS"
                      },
                      "TargetVisualsConfiguration": {
                        "SameSheetTargetVisualConfiguration": {
                          "TargetVisualOptions": "ALL_VISUALS"
                        }
                      }
                    }
                  }
                ],
                "CustomActionId": "4b6e5804-3ec2-48b3-b85f-2ecbb4b88e27",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "LabelContent": "VALUE",
                "MeasureLabelVisibility": "VISIBLE",
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "regionname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.regionname.2.1694436106781",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589667250"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589667250"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.regionname.2.1694436106781",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589667250",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal alarmen per regio</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5b91633a-99ed-4dbd-9f24-2a25906fd84b"
          }
        },
        {
          "PieChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "CategoryLabelVisibility": "HIDDEN",
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "MeasureLabelVisibility": "HIDDEN",
                "Overlap": "DISABLE_OVERLAP",
                "Position": "OUTSIDE",
                "Visibility": "HIDDEN"
              },
              "DonutOptions": {
                "ArcOptions": {
                  "ArcThickness": "MEDIUM"
                }
              },
              "FieldWells": {
                "PieChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.1.1694508926585",
                        "FormatConfiguration": null,
                        "HierarchyId": null
                      },
                      "DateDimensionField": null,
                      "NumericalDimensionField": null
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589650330"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "VISIBLE",
                "Width": "106px"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589650330"
                    }
                  }
                ],
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.1.1694508926585",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.1.1694589650330",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal alarmen per shift</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "e631fa47-b926-4b55-ad15-1eb2b93de783"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "BarsArrangement": "STACKED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "CategoricalDimensionField": null,
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "WEEK",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694510949495",
                        "FormatConfiguration": null,
                        "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694510949495"
                      },
                      "NumericalDimensionField": null
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1694589660621"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "VISIBLE",
                "Width": "100px"
              },
              "Orientation": "VERTICAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694510949495"
                    }
                  }
                ],
                "ColorItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "SmallMultiplesLimitConfiguration": {
                  "OtherCategories": "INCLUDE"
                }
              },
              "Tooltip": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694510949495",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.2.1694589660621",
                        "Visibility": "VISIBLE"
                      }
                    }
                  ],
                  "TooltipTitleType": "PRIMARY_VALUE"
                },
                "SelectedTooltipType": "BASIC",
                "TooltipVisibility": "VISIBLE"
              },
              "ValueAxis": {
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "ValueLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              }
            },
            "ColumnHierarchies": [
              {
                "DateTimeHierarchy": {
                  "DrillDownFilters": [],
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.0.1694510949495"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Aantal alarmen per week</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "73001c5f-a33e-471a-98a4-acc57015733e"
          }
        }
      ]
    }
  ]
}
EOT
}

resource "specifai_quicksight_dashboard" "test" {
  dashboard_id = "terraform-provider-test-dashboard"
  name = "Terraform Provider Test Dashboard"
  version_description = "..."
  definition = data.specifai_normalized_dashboard_definition.test.normalized_definition
  permissions = [
    {
      principal = "arn:aws:quicksight:eu-west-1:296896140035:user/default/quicksight_sso/marcel@meulemans.engineering",
      actions = [
        "quicksight:DescribeDashboard",
        "quicksight:ListDashboardVersions",
        "quicksight:QueryDashboard"
      ]
    }
  ]
}

# output "dashboard" {
#   value = data.specifai_quicksight_dashboard.test
# }

# output "definition" {
#   value = data.specifai_normalized_dashboard_definition.test
# }
