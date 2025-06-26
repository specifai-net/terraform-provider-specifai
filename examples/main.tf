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
      "Expression": "ifelse($${Scandata}=\"Aantal scans\", sum({stefan - correct gescant}) / count(taskid), sum({stefan - correct gescant}) / sum({stefan - correct gescant}))",
      "Name": "Percentage handmatig gescand"
    },
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "ifelse(\r\n$${dateSelectionAggregation}='1. Dag',truncDate(\"DD\",scanneddatetime),\r\n$${dateSelectionAggregation}='2. Week',truncDate(\"WK\",scanneddatetime),\r\n$${dateSelectionAggregation}='3. Maand', truncDate(\"MM\",scanneddatetime),\r\n$${dateSelectionAggregation}='4. Kwartaal',truncDate(\"Q\",scanneddatetime),\r\n\r\ntruncDate(\"YYYY\",scanneddatetime))",
      "Name": "datum1"
    },
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "ifelse($${Scandata}=\"Aantal scans\", count(taskid),\r\nsum(scanerror)\r\n)",
      "Name": "scandataselectie"
    },
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "ifelse(\n    manuallyscanned = 1,\n    1,\n    0\n)",
      "Name": "scanerror"
    },
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "ifelse($${scansselect}=\"Object\", objectname,\r\n$${scansselect}=\"Regio\", regionname,\r\n$${scansselect}=\"Locatie\", location,\r\nemployee)",
      "Name": "scanselectie"
    },
    {
      "DataSetIdentifier": "sequrix_planning_records",
      "Expression": "ifelse(\r\n    manuallyscanned = 0,\r\n    1,\r\n    0\r\n)",
      "Name": "stefan - correct gescant"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "sumOver(turnover, [], PRE_AGG) / sumOver({stefan - totaal hours alarmtype} , [], PRE_AGG)",
      "Name": " stefan turnoveer"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Selectie}= 'Taken Uitgevoerd Binnen Tijdslimiet',  {Uitvoering Binnen Tijdslimit},\r\n $${Selectie}= 'Taken Uitgevoerd Volgens Rooster', {Uitgevoerd Volgens Rooster },\r\n $${Selectie}= 'Alarmopvolgingen', distinct_count( ifelse(productname=\"Alarmopvolging\", taskid, NULL)) / distinct_count(taskid),\r\n$${Selectie}= 'Overschreden Aanrijtijden', {stefan - persentage overschreden traveltime},\r\n$${Selectie}= 'Gemiddelde Aanrijtijd', {stefan - persentage overschreden traveltime},\r\n$${Selectie}= 'Diensten Vroegtijdige Beëindigd', distinct_count({Parameter workshift_delay_check}) / distinct_count(taskid),                 \r\n$${Selectie}= 'Diensten Te laat begonnen', distinct_count({parameter workshift_start_delay_check})/ distinct_count(taskid),  \r\n$${Selectie}= 'Taken Uitgevoerd Buiten Rooster', {percentage begonnen task buiten geplande tijd},\r\n$${Selectie}= 'Totaal Aantal Taken Afgerond', distinct_count( ifelse(taskstate=\"Finished\", taskid,NULL)) / distinct_count(taskid),\r\n$${Selectie}= 'Taken Uitgevoerd Buiten Tijdslimiet',  distinct_count({Taskid _buiten_de_tijdslimiet}) / distinct_count(ifelse(\r\nisNotNull(duration) AND \r\nisNotNull({duur_werkzaamheden})\r\n, taskid, NULL)),                                     \r\n                                    \r\n                                    \r\n                                    \r\n                                    \r\n                                     NULL\r\n        )\r\n",
      "Name": "(Aanslutingen) selectie grafiek 2"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "periodOverPeriodLastValue({(Aanslutingen) selectie grafiek 2},Datum1, YEAR, 1)",
      "Name": "(Aanslutingen) selectie grafiek 2 Last year"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Medewerker}= 'Taken Uitgevoerd Binnen Tijdslimiet',  {Uitvoering Binnen Tijdslimit},\r\n$${Medewerker}= 'Taken Uitgevoerd Volgens Rooster', {Uitgevoerd Volgens Rooster },\r\n$${Medewerker}= 'Taken Uitgevoerd Buiten Rooster', {percentage begonnen task buiten geplande tijd},\r\n$${Medewerker}= 'Overschreden Aanrijtijden', {stefan - persentage overschreden traveltime},\r\n$${Medewerker}= 'Gemiddelde Aanrijtijd', {stefan - persentage overschreden traveltime},\r\n$${Medewerker}= 'Diensten Vroegtijdig Beëindigd', distinct_count({Parameter workshift_delay_check}) / distinct_count(workshiftid),                 \r\n$${Medewerker}= 'Diensten Te laat begonnen', distinct_count({parameter workshift_start_delay_check})/ distinct_count(workshiftid),  \r\n$${Medewerker}= 'Taken Uitgevoerd Buiten Tijdslimiet',  distinct_count({Taskid _buiten_de_tijdslimiet}) / distinct_count(ifelse(\r\nisNotNull(duration) AND \r\nisNotNull({duur_werkzaamheden})\r\n, taskid, NULL)),                        \r\n                                    \r\n                                    \r\n                                    \r\n                                    \r\n                                     NULL\r\n        )\r\n",
      "Name": "(Medewerkers) Grafiek 2"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Medewerker}= 'Overschreden Aanrijtijden', distinct_count( ifelse(\r\n                                    traveltime > {maxtraveltime (with default)},\r\n                                    taskid,\r\n                                     NULL\r\n                                    )),\r\n\r\n$${Medewerker}= 'Taken Uitgevoerd Volgens Rooster', distinct_count({Parameter Uitgevoerd Binnen Rooster task}),\r\n$${Medewerker}= 'Taken Uitgevoerd Binnen Tijdslimiet', distinct_count({parameter Taskid _binnen_de_tijdslimiet}),\r\n$${Medewerker}= 'Diensten Vroegtijdig Beëindigd', distinct_count({Parameter workshift_delay_check}),                 \r\n$${Medewerker}= 'Diensten Te laat begonnen', distinct_count({parameter workshift_start_delay_check}),                               \r\n$${Medewerker}= 'Taken Uitgevoerd Buiten Rooster', distinct_count({parameter task_block_time_mismatch_check}),\r\n$${Medewerker}= 'Taken Uitgevoerd Buiten Tijdslimiet', distinct_count({Taskid _buiten_de_tijdslimiet}),\r\n\r\n                                    \r\n                                    \r\n                                     NULL\r\n        )\r\n",
      "Name": "(Medewerkers) grafiek 1"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n$${ControlOpbrengsten} = 'Risicoadressen', objectname,\r\n$${ControlOpbrengsten} = 'Klanten', customername,\r\n$${ControlOpbrengsten} = 'Dienstenverlening', productname,\r\n$${ControlOpbrengsten} = 'Regio', regionname,\r\nworkshiftname)",
      "Name": "(Opbrengsten) table"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n  $${StatiscsAantal} = \"Aantal Taken\", distinct_count(taskid),\r\n  $${StatiscsAantal} = \"Overschreden Aanrijtijden\", distinct_count({Traveltime exceeded geef id terug wegen dubble id}),\r\n  $${StatiscsAantal} = \"Diensten Vroegtijdige Beëindigd\", distinct_count({Parameter workshift_delay_check}),\r\n  $${StatiscsAantal} = \"Diensten Te laat begonnen\", distinct_count({parameter workshift_start_delay_check}),\r\n  $${StatiscsAantal} = \"Taken Uitgevoerd Buiten Rooster\", distinct_count({parameter task_block_time_mismatch_check}),\r\n  $${StatiscsAantal} = \"Taken Uitgevoerd Buiten Tijdslimiet\", distinct_count({parameter Taskid _binnen_de_tijdslimiet}),\r\n  $${StatiscsAantal} = \"Gemiddelde Reistijd\", avg(traveltime),\r\n  $${StatiscsAantal} = \"Gemiddelde Uitvoertijd Taak\", avg(duration),\r\n  \r\n  $${StatiscsAantal} = \"Alarmopvolgingen\", distinct_count(ifelse(productname = 'Alarmopvolging', taskid, NULL)), NULL\r\n)\r\n",
      "Name": "(Statics)Aantal taken Per Uur Van de Dag"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n$${ControlAansluiting} = 'Klanten', customername,\r\n$${ControlAansluiting} = 'Dienstenverlening', productname,\r\n$${ControlAansluiting} = 'Alarmtype', alarmtype,\r\n$${ControlAansluiting} = 'Prio', {alarmtype prio},\r\n$${ControlAansluiting} = 'Eindreden', endreason,\r\n\r\nobjectname)",
      "Name": "(aansluiting) Table "
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Selectie}= 'Overschreden Aanrijtijden', distinct_count( ifelse(\r\n                                    traveltime > {maxtraveltime (with default)},\r\n                                    taskid,\r\n                                     NULL\r\n                                    )),\r\n\r\n\r\n $${Selectie}= 'Diensten Vroegtijdige Beëindigd', distinct_count({Parameter workshift_delay_check}),                 \r\n$${Selectie}= 'Diensten Te laat begonnen', distinct_count({parameter workshift_start_delay_check}),                               \r\n $${Selectie}= 'Taken Uitgevoerd Buiten Rooster', distinct_count({parameter task_block_time_mismatch_check}),\r\n$${Selectie}= 'Taken Uitgevoerd Buiten Tijdslimiet', distinct_count({Taskid _buiten_de_tijdslimiet}),                                  \r\n$${Selectie}= 'Alarmopvolgingen', distinct_count( ifelse(productname=\"Alarmopvolging\", taskid, NULL)),                                           \r\n$${Selectie}= 'Totaal Aantal Taken Afgerond', distinct_countIf(taskid, taskstate=\"Finished\"),                                      \r\n                                     NULL\r\n        )\r\n",
      "Name": "(aansluitingen) selectie grafiek 1"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "periodOverPeriodLastValue({(aansluitingen) selectie grafiek 1}, Datum1, YEAR, 1)",
      "Name": "(aanslutingen) last YEar"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Selectedparameter}=workshiftid, 10, .5)",
      "Name": "(diensten) selectie geel"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${ControlMedewerker} = 'Medewerkers', employee,\r\nworkshiftname)",
      "Name": "(medewerkers) Table"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse({filter datum}=1, turnover, NULL)\r\n",
      "Name": "(opbrengsten) Grafiek 1"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "\r\n\r\n ifelse($${Opbrengsten}='Totale Omzet', {stefan - totaal hours alarmtype}, \r\n$${Opbrengsten}='Totale Omzet(Per Regio)', {stefan - totaal hours alarmtype},\r\n$${Opbrengsten}='Totale Omzet(Product)', {stefan - totaal hours alarmtype},\r\n$${Opbrengsten}='Opbrengsten per uur',{stefan - totaal hours alarmtype},\r\n$${Opbrengsten}='Opbrengsten per uur(Per Regio)',{stefan - totaal hours alarmtype},\r\n NULL)",
      "Name": "(opbrengsten) grafiek 2"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${StatiscsAantal}=\"Gemiddeld Aantal Taken\", distinct_count(taskid) / avg(dateDiff($${from},$${to},\"MM\")),distinct_count( ifelse(\r\n                                    traveltime > {maxtraveltime (with default)},\r\n                                    taskid,\r\n                                     NULL\r\n                                    )))",
      "Name": "(statics)Aantal taken per dag van de Month"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${StatiscsAantal}=\"Gemiddeld Aantal Taken\", distinct_count(taskid) / avg(dateDiff($${from},$${to},\"WK\")),distinct_count( ifelse(\r\n                                    traveltime > {maxtraveltime (with default)},\r\n                                    taskid,\r\n                                     NULL\r\n                                    )))",
      "Name": "(statics)Aantal taken per dag van de week"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(extract('WD', started) = 1, '7 - Zondag',\r\n    ifelse(extract('WD', started) = 2, '1 - Maandag',\r\n        ifelse(extract('WD', started) = 3, '2 - Dinsdag',\r\n            ifelse(extract(\"WD\", started) = 4, '3 - Woensdag',\r\n                ifelse(extract('WD', started) = 5, '4 - Donderdag',\r\n                    ifelse(extract('WD', started) = 6, '5 - Vrijdag',\r\n                        '6 - Zaterdag'\r\n                    )\r\n                )\r\n            )\r\n        )\r\n    )\r\n)",
      "Name": "Dag van de Week"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "concat(\r\n  toString(extract('HH', started)), ':',\r\n  ifelse(extract('MI', started) < 10, concat('0', toString(extract('MI', started))), toString(extract('MI', started))),\r\n  ' tot ',\r\n  toString(extract('HH', ended)), ':',\r\n  ifelse(extract('MI', ended) < 10, concat('0', toString(extract('MI', ended))), toString(extract('MI', ended)))\r\n)\r\n",
      "Name": "Date to string"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n$${dateSelectionAggregation}='1. Dag',truncDate(\"DD\",started),\r\n$${dateSelectionAggregation}='2. Week',truncDate(\"WK\",started),\r\n$${dateSelectionAggregation}='3. Maand', truncDate(\"MM\",started),\r\n$${dateSelectionAggregation}='4. Kwartaal',truncDate(\"Q\",started),\r\n\r\ntruncDate(\"YYYY\",started))\r\n",
      "Name": "Datum1"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "dateDiff(workshiftactualstarted, workshiftactualended, \"MI\")",
      "Name": "Duration workshift actual"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Medewerker}= 'Overschreden Aanrijtijden',  ifelse(\r\n                                    traveltime > {maxtraveltime (with default)},\r\n                                    \"Overschreden Aanrijtijden\",\r\n                                     NULL\r\n                                    ),\r\n\r\n$${Medewerker}= 'Taken Uitgevoerd Volgens Rooster', ifelse({Parameter Uitgevoerd Binnen Rooster task} >= 1, 'Taken Uitgevoerd Volgens Rooster',NULL),\r\n$${Medewerker}= 'Taken Uitgevoerd Binnen Tijdslimiet', ifelse({parameter Taskid _binnen_de_tijdslimiet}>= 1, 'Taken Uitgevoerd Binnen Tijdslimiet',NULL),\r\n$${Medewerker}= 'Taken Uitgevoerd Buiten Tijdslimiet', ifelse({Taskid _buiten_de_tijdslimiet}>= 1, 'Taken Uitgevoerd Buiten Tijdslimiet',NULL),\r\n$${Medewerker}= 'Diensten Vroegtijdig Beëindigd', ifelse({Parameter workshift_delay_check}>= 1, \"Diensten Vroegtijdige Beëindigd\",NULL),                 \r\n$${Medewerker}= 'Diensten Te laat begonnen', ifelse({parameter workshift_start_delay_check}>= 1, \"Diensten Te laat begonnen\",NULL),                               \r\n$${Medewerker}= 'Taken Uitgevoerd Buiten Rooster', ifelse({parameter task_block_time_mismatch_check}>= 1, \"Taken Uitgevoerd Buiten Rooster\",NULL),                                    \r\n                                    \r\n                                    \r\n                                     NULL\r\n        )\r\n",
      "Name": "Medewerkers"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    extract('MM', started)=1, '01-jan',\r\n    extract('MM', started)=2, '02-feb',\r\n    extract('MM', started)=3, '03-mrt',\r\n    extract('MM', started)=4, '04-apr',\r\n    extract('MM', started)=5, '05-mei',\r\n    extract('MM', started)=6, '06-jun',\r\n    extract('MM', started)=7, '07-jul',\r\n    extract('MM', started)=8, '08-aug',\r\n    extract('MM', started)=9, '09-sep',\r\n    extract('MM', started)=10, '10-okt',\r\n    extract('MM', started)=11, '11-nov',\r\n        '12-Dec'    )",
      "Name": "Month"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNull(employee), \" \", employee)",
      "Name": "Null filter"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(sum({(opbrengsten) Grafiek 1}) > 1, periodOverPeriodLastValue(sum(turnover), Datum1, YEAR, 1), NULL) ",
      "Name": "Omzet last Year"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "sum(turnover) / sum({stefan - totaal hours alarmtype})",
      "Name": "Omzet per uur"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "periodOverPeriodLastValue({Omzet per uur}, Datum1, YEAR, 1)",
      "Name": "Omzet per uur last Year"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\nisNotNull(blockstarttime) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(started) AND \r\nisNotNull(ended) AND \r\ndateDiff(blockstarttime, started, \"MI\") > -10 AND dateDiff(ended, blockendtime, \"MI\") > -5, taskid, NULL)\r\n",
      "Name": "Parameter Uitgevoerd Binnen Rooster task"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(dateDiff(workshiftended, workshiftactualended, \"MI\") > $${Margendtimetask}, workshiftid , NULL)",
      "Name": "Parameter workshift_delay_check"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    ({duur_werkzaamheden} - duration) < -($${margeDuurTaakTekort}) OR ({duur_werkzaamheden} - duration) > $${margeDuurTaakTeLang} AND \r\n    isNotNull(duration) AND isNotNull({duur_werkzaamheden}), \r\n    taskid, \r\n    NULL\r\n)",
      "Name": "Taskid _buiten_de_tijdslimiet"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "dateDiff(started, ended, \"HH\")",
      "Name": "Test_Task_total house"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count(taskid) * avg({Test_Task_total house})",
      "Name": "Test_bezetting"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "{test_bezetting alarmopvolgingen} / (sum(workshifttotalhours) * ($${Productiviteitsverlies} / 100)) \r\n\r\n",
      "Name": "Test_bezetting alarmopvolging"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "{Test_bezetting} / sum(workshifttotalhours)",
      "Name": "Test_bezettinggraad"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "periodOverPeriodLastValue(sum({stefan - totaal hours alarmtype}), Datum1, YEAR, 1)",
      "Name": "Totaal hours last Year"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "//De voorwaarde die je wilt testen (traveltime > maxtraveltime).\r\n//De waarde die moet worden geretourneerd als de voorwaarde waar is (taskid).\r\n//De waarde die moet worden geretourneerd als de voorwaarde niet waar is (null).\r\n\r\n\r\n\r\nifelse(\r\n    traveltime > {maxtraveltime (with default)},\r\n    taskid,\r\n    NULL\r\n)",
      "Name": "Traveltime exceeded geef id terug wegen dubble id"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "// ifelse() wordt gebruikt om te controleren of bepaalde voorwaarden waar zijn. Als ze waar zijn, wordt taskid geretourneerd; anders wordt NULL geretourneerd.\r\n//distinct_count() wordt gebruikt om het aantal unieke waarden te tellen. In de teller tellen we de unieke waarden van {stefan - Duur werkzaamheden overschreden %} en in de noemer tellen we de unieke waarden van taskid waar de specifieke voorwaarden gelden.\r\n\r\n// gebruikt voor dubble ids\r\ndistinct_count({Parameter Uitgevoerd Binnen Rooster task}) / distinct_count(ifelse(\r\nisNotNull(blockstarttime) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(started) AND \r\nisNotNull(ended)\r\n,taskid, NULL))",
      "Name": "Uitgevoerd Volgens Rooster "
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "//ifelse() wordt gebruikt om te controleren of bepaalde voorwaarden waar zijn. Als ze waar zijn, wordt taskid geretourneerd; anders wordt NULL geretourneerd.\r\n//distinct_count() wordt gebruikt om het aantal unieke waarden te tellen. In de teller tellen we de unieke waarden van {stefan - Duur werkzaamheden overschreden %} en in de noemer tellen we de unieke waarden van taskid waar de specifieke voorwaarden gelden.\r\n\r\n//Dit is nodig voor dubble ids\r\ndistinct_count({parameter Taskid _binnen_de_tijdslimiet}) / distinct_count(ifelse(\r\nisNotNull(duration) AND \r\nisNotNull({duur_werkzaamheden})\r\n, taskid, NULL))",
      "Name": "Uitvoering Binnen Tijdslimit"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(workshiftactualstarted <= workshiftstarted, 0 ,dateDiff(workshiftstarted, workshiftactualstarted, \"MI\") )",
      "Name": "Workshift te laat begonnen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(workshiftactualended>=workshiftended, 0 ,dateDiff(workshiftactualended, workshiftended, \"MI\") )",
      "Name": "Workshift te vroeg gestopt"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "toString(extract('YYYY', started))",
      "Name": "Year"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Selectie}= 'Overschreden Aanrijtijden',  ifelse(\r\n                                    traveltime > {maxtraveltime (with default)},\r\n                                    \"Overschreden Aanrijtijden\",\r\n                                     NULL\r\n                                    ),\r\n$${Selectie}= 'Totaal Aantal Taken Afgerond', ifelse(taskstate=\"Finished\", \"False\", NULL),  \r\n$${Selectie}= 'Taken Uitgevoerd Volgens Rooster', ifelse({Parameter Uitgevoerd Binnen Rooster task} >= 1, 'Taken Uitgevoerd Volgens Rooster',NULL),\r\n$${Selectie}= 'Taken Uitgevoerd Binnen Tijdslimiet', ifelse({parameter Taskid _binnen_de_tijdslimiet}>= 1, 'Taken Uitgevoerd Binnen Tijdslimiet',NULL),\r\n$${Selectie}= 'Taken Uitgevoerd Buiten Tijdslimiet', ifelse({Taskid _buiten_de_tijdslimiet}>= 1, 'Taken Uitgevoerd Buiten Tijdslimiet',NULL),\r\n$${Selectie}= 'Diensten Vroegtijdige Beëindigd', ifelse({Parameter workshift_delay_check}>= 1, \"Diensten Vroegtijdige Beëindigd\",NULL),                 \r\n$${Selectie}= 'Diensten Te laat begonnen', ifelse({parameter workshift_start_delay_check}>= 1, \"Diensten Te laat begonnen\",NULL),                               \r\n$${Selectie}= 'Taken Uitgevoerd Buiten Rooster', ifelse({parameter task_block_time_mismatch_check}>= 1, \"Taken Uitgevoerd Buiten Rooster\",NULL),                                    \r\n$${Selectie}= 'Alarmopvolgingen', ifelse(productname=\"Alarmopvolging\", \"Alarmopvolgingen\", NULL),                                     \r\n                                    \r\n                                     NULL\r\n        )\r\n",
      "Name": "aansluitingen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(endreason = \"Succesvol afgerond\" OR endreason = \"Succesvol afgerond met bijzonderheden\", taskid, NULL)",
      "Name": "afgeronde alarmen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "dateDiff(started, ended, \"MI\")",
      "Name": "duur_werkzaamheden"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n$${dateSelectionAggregation}='1. Dag',ifelse(\r\n    Datum1 >= addDateTime(-30, 'DD', truncDate('DD', $${to})),\r\n    1,\r\n    0\r\n),\r\n$${dateSelectionAggregation}='2. Week', ifelse(\r\n    Datum1 >= addDateTime(-11, 'MM', truncDate('WK', $${to})),\r\n    1,\r\n    0\r\n),\r\n$${dateSelectionAggregation}='3. Maand', ifelse(\r\n    Datum1 >= addDateTime(-11, 'MM', truncDate('MM', $${to})),\r\n    1,\r\n    0\r\n),\r\n$${dateSelectionAggregation}='4. kwartaal',ifelse(\r\n    Datum1 >= addDateTime(-16, 'Q', truncDate('Q', $${to})),\r\n    1,\r\n    0\r\n),\r\n1)\r\n\r\n",
      "Name": "filter datum"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "// Set to a default value of 30 minutes\nifelse(\n    isNotNull(maxtraveltime), maxtraveltime,\n    {alarmtype prio} = 'Prio-1', 30.0,\n    {alarmtype prio} = 'Prio-2', 60.0,\n    $${MinimaleTravellimit}\n)",
      "Name": "maxtraveltime (with default)"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse( \r\n        ({duur_werkzaamheden} - duration) < -10, NULL, \r\n        ({duur_werkzaamheden} - duration) > 5, NULL, \r\nisNotNull(duration) AND \r\nisNotNull({duur_werkzaamheden}  \r\n    ), taskid,  NULL) ",
      "Name": "parameter Taskid _binnen_de_tijdslimiet"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\nisNotNull(blockstarttime) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(started) AND \r\nisNotNull(ended) AND \r\ndateDiff(blockstarttime, started, \"MI\") < -($${Margestarttimetask}) OR dateDiff(ended, blockendtime, \"MI\") < -($${Margendtimetask}), taskid, NULL)\r\n",
      "Name": "parameter task_block_time_mismatch_check"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(dateDiff(workshiftstarted, workshiftactualstarted, \"MI\") > $${Margestartshift}, workshiftid , NULL)",
      "Name": "parameter workshift_start_delay_check"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count({parameter task_block_time_mismatch_check}) / distinct_count(ifelse(\r\nisNotNull(blockstarttime) AND \r\nisNotNull(blockendtime) AND \r\nisNotNull(started) AND \r\nisNotNull(ended)\r\n,taskid, NULL))",
      "Name": "percentage begonnen task buiten geplande tijd"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    traveltime > {maxtraveltime (with default)},\r\n    taskid,\r\n    NULL\r\n)",
      "Name": "reistijd overschreden"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse($${Selectedparameter}=workshiftid,\"selected\",\"others\")",
      "Name": "selected_workshift"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "sum(turnover) / sum({stefan - totaal hours alarmtype})",
      "Name": "stefan -  object turnover per hour"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse( endreason= \"Succesvol afgerond\" OR endreason= \"Succesvol afgerond met bijzonderheden\" OR endreason= \"Taak overgedragen\" , NULL, taskid)",
      "Name": "stefan - Overig"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse({stefan - persentage overschreden traveltime} > 0, 0.95 , 0)",
      "Name": "stefan - Uitvoering binnen tijdslimiet 95%"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\r\n    traveltime < {maxtraveltime (with default)},\r\n    taskid,\r\n    NULL\r\n)",
      "Name": "stefan - percentage rijdtijd volgens tijd uitgevoerd"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count({Traveltime exceeded geef id terug wegen dubble id}) / distinct_count(ifelse(\r\nisNotNull(traveltime) \r\n, taskid, NULL))",
      "Name": "stefan - persentage overschreden traveltime"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count({stefan - percentage rijdtijd volgens tijd uitgevoerd}) / distinct_count(ifelse(\r\nisNotNull(traveltime) \r\n, taskid, NULL))",
      "Name": "stefan - prestataiedashboard percentage niet overschreden aantijdtijden"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(traveltime > 1 AND turnover >1 , ({duur_werkzaamheden} + traveltime) /60, turnover > 1, {duur_werkzaamheden} / 60, NULL)",
      "Name": "stefan - totaal hours alarmtype"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNotNull(started) AND isNotNull(ended) AND isNotNull(blockendtime) AND isNotNull(duration) AND \r\ndateDiff(ended, blockendtime, \"MI\") > 5, NULL, dateDiff(blockendtime, ended, \"MI\"))",
      "Name": "taak te laat uitgevoerd"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(isNotNull(started) AND isNotNull(ended) AND \r\ndateDiff(blockstarttime, started, \"MI\") > -10, NULL, dateDiff(blockstarttime, started, \"MI\"))",
      "Name": "taak te vroeg begonnen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "distinct_count(taskid) * (avg({Test_Task_total house}) + avg(coalesce(traveltime, $${Traveltime}) / 60))",
      "Name": "test_bezetting alarmopvolgingen"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(\n    traveltime > {maxtraveltime (with default)},\n    1,\n    0\n)",
      "Name": "traveltime exceeded"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(extract('WD', started) = 1, '7 - Sunday',\n    ifelse(extract('WD', started) = 2, '1 - Monday',\n        ifelse(extract('WD', started) = 3, '2 - Tuesday',\n            ifelse(extract('WD', started) = 4, '3 - Wednesday',\n                ifelse(extract('WD', started) = 5, '4 - Thursday',\n                    ifelse(extract('WD', started) = 6, '5 - Friday',\n                        '6 - Saturday'\n                    )\n                )\n            )\n        )\n    )\n)",
      "Name": "workshift - day of the week"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "sum(turnover) / sum(workshifttotalhours)",
      "Name": "workshift turnover per hour"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "avgOver(dateDiff(workshiftstarted, workshiftended, \"MI\") / 60, [workshiftid], PRE_FILTER)",
      "Name": "workshifthours"
    },
    {
      "DataSetIdentifier": "sequrix_tasks_records",
      "Expression": "ifelse(maxOver(taskid, [workshiftid], PRE_AGG) = taskid, workshifthours, NULL)",
      "Name": "workshifttotalhours"
    }
  ],
  "ColumnConfigurations": [
    {
      "Column": {
        "ColumnName": "Percentage handmatig gescand",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "accuracy",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 1
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "distancetocheckpointlocation",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 1
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "gpsfixdatetime",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "manuallyscanned",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "planningresultcheckpointid",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "HIDDEN"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "scandataselectie",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "scanerror",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "scanneddatetime",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "stefan - correct gescant",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "Role": "DIMENSION"
    },
    {
      "Column": {
        "ColumnName": "taskid",
        "DataSetIdentifier": "sequrix_planning_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "HIDDEN"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": " stefan turnoveer",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 2
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "POSITIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "DOT",
                "ThousandsSeparator": {
                  "Symbol": "COMMA",
                  "Visibility": "VISIBLE"
                }
              },
              "Symbol": "USD"
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "(Aanslutingen) selectie grafiek 2 Last year",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "(Statics)Aantal taken Per Uur Van de Dag",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "(aansluitingen) selectie grafiek 1",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "(aanslutingen) last YEar",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "(opbrengsten) grafiek 2",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "(statics)Aantal taken per dag van de Month",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 2
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "(statics)Aantal taken per dag van de week",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "DOT",
                "ThousandsSeparator": {
                  "Symbol": "COMMA",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "Datum1",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "Role": "DIMENSION"
    },
    {
      "Column": {
        "ColumnName": "Null filter",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "Role": "DIMENSION"
    },
    {
      "Column": {
        "ColumnName": "Omzet last Year",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 2
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "POSITIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "DOT",
                "ThousandsSeparator": {
                  "Symbol": "COMMA",
                  "Visibility": "VISIBLE"
                }
              },
              "Symbol": "EUR"
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "Omzet per uur",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 2
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "POSITIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "DOT",
                "ThousandsSeparator": {
                  "Symbol": "COMMA",
                  "Visibility": "VISIBLE"
                }
              },
              "Symbol": "EUR"
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "Omzet per uur last Year",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 2
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "POSITIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "DOT",
                "ThousandsSeparator": {
                  "Symbol": "COMMA",
                  "Visibility": "VISIBLE"
                }
              },
              "Symbol": "USD"
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "Parameter Uitgevoerd Binnen Rooster task",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "Role": "DIMENSION"
    },
    {
      "Column": {
        "ColumnName": "Taskid _buiten_de_tijdslimiet",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "Role": "DIMENSION"
    },
    {
      "Column": {
        "ColumnName": "Test_bezetting alarmopvolging",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "Test_bezettinggraad",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "Traveltime exceeded geef id terug wegen dubble id",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "Role": "DIMENSION"
    },
    {
      "Column": {
        "ColumnName": "Uitgevoerd Volgens Rooster ",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "Uitvoering Binnen Tijdslimit",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "accepted",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "blockendtime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "blockstarttime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "customerid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "duur_werkzaamheden",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "ended",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "objectid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "onlocation",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "spenttimeinvoice",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "spenttimetotal",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "started",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "DD/MM/YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "stefan - persentage overschreden traveltime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "PercentageDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NegativeValueConfiguration": {
                "DisplayMode": "NEGATIVE"
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
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
      "Column": {
        "ColumnName": "taskid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "VISIBLE"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "traveltime",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 1
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "traveltime exceeded",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
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
    },
    {
      "Column": {
        "ColumnName": "turnover",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "DOT",
                "ThousandsSeparator": {
                  "Symbol": "COMMA",
                  "Visibility": "HIDDEN"
                }
              },
              "Symbol": "EUR"
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshift - day of the week",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "Role": "MEASURE"
    },
    {
      "Column": {
        "ColumnName": "workshift turnover per hour",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "CurrencyDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT"
                }
              },
              "Symbol": "EUR"
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshiftactualended",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshiftactualstarted",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshiftended",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshifthours",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "NumberScale": "NONE",
              "SeparatorConfiguration": {
                "ThousandsSeparator": {
                  "Visibility": "HIDDEN"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshiftid",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "DecimalSeparator": "COMMA",
                "ThousandsSeparator": {
                  "Symbol": "DOT",
                  "Visibility": "HIDDEN"
                }
              }
            }
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshiftstarted",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "DateTimeFormatConfiguration": {
          "DateTimeFormat": "MMM D, YYYY H:mm",
          "NullValueFormatConfiguration": {
            "NullString": "null"
          }
        }
      }
    },
    {
      "Column": {
        "ColumnName": "workshifttotalhours",
        "DataSetIdentifier": "sequrix_tasks_records"
      },
      "FormatConfiguration": {
        "NumberFormatConfiguration": {
          "FormatConfiguration": {
            "NumberDisplayFormatConfiguration": {
              "DecimalPlacesConfiguration": {
                "DecimalPlaces": 0
              },
              "NullValueFormatConfiguration": {
                "NullString": "null"
              },
              "SeparatorConfiguration": {
                "ThousandsSeparator": {
                  "Visibility": "HIDDEN"
                }
              }
            }
          }
        }
      }
    }
  ],
  "DataSetIdentifierDeclarations": [
    {
      "DataSetArn": "arn:aws:quicksight:eu-west-1:296896140035:dataset/ds-ds5i0y02221rgjcopf",
      "Identifier": "sequrix_tasks_records"
    },
    {
      "DataSetArn": "arn:aws:quicksight:eu-west-1:296896140035:dataset/ds-a4nh1ev3kdn3cy8srf",
      "Identifier": "sequrix_planning_records"
    }
  ],
  "FilterGroups": [
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "3d3b6db8-feb3-4cc9-89e1-2625a4ba5725",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Dag van de Week",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "e1cd4136-e232-4664-8342-5fdca7766fc8"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "f8d06d5a-7c51-4d88-8c0e-2cc927c1ad8f",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "CategoryValues": [
                  "Alliance Automotive Group Benelux B.V. l Kantoor + Hal 8",
                  "Axa Stenman Industries B.V.",
                  "Bedrijfsverzamelgebouw Saeckenborgh",
                  "Brooks Instrument B.V.",
                  "CTB",
                  "Carbogen Amcis B.V.",
                  "Colson Europe B.V.",
                  "Corpeq Real Estate B.V.",
                  "Crow",
                  "De Cultuurfabriek",
                  "Detron ICT Rental Solutions BV",
                  "Diviande B.V. - Jan Zandbergen",
                  "Dustin Supply Chain Netherlands B.V.",
                  "EBM Beton + EBC",
                  "GePuKo Vastgoed B.V.",
                  "Gezondheidscentrum Veenendaal",
                  "Giant Europe Manufacturing B.V.",
                  "HSO Nederland B.V. | Hoofdgebouw",
                  "Heijmans Facilitair",
                  "Helix",
                  "Invacare B.V.",
                  "Jan Zandbergen B.V. l hoofdkantoor",
                  "Jan Zandbergen Group - Food Innovation Center",
                  "Landgoed Prattenburg",
                  "Larserpoort (Lelystad)",
                  "Leeuwenborch",
                  "Leger des Heils Hoofdkantoor",
                  "Lelystad Airport Businesspark",
                  "Mevr. M. Bastin",
                  "Mitsubishi Elevator Europe B.V.",
                  "Mprise Group B.V.",
                  "NIOO-KNAW",
                  "Oldelft Benelux B.V.",
                  "Profile Int, N.V.  (De Generaal)",
                  "Prometheus Informatics B.V.",
                  "S.C. van Ravenswaaij B.V.",
                  "Sanorice Netherlands B.V.",
                  "Schenker Logistics Nederland B.V.",
                  "Schipper Security B.V. l Vestiging Flevoland",
                  "Serviceflat Belvedere Ede",
                  "Sibbing & Wateler Holding B.V.",
                  "Solarpark Avri - Geldermalsen",
                  "Solarpark Biddinghuizen",
                  "Stichting Bewaarder Steadfast Beleggingen",
                  "VONK360",
                  "Van Putten van Apeldoorn notarissen",
                  "Van der Heiden Cheese Services B.V.",
                  "WBVR (Wageningen BioVeterinary Research)",
                  "Wave Vastgoed B.V.",
                  "Zodiac",
                  "Zonnepark Lelystad BEE (Zonnestroom service)",
                  "De Kleuver bedrijfscommunicatie"
                ],
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY"
              }
            },
            "FilterId": "bddcab14-4bce-4efd-8401-741d0334b62f"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e",
              "VisualIds": [
                "45c0fbc5-cfe1-4ddc-ade0-547cc61e47e7"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "9a64840f-ca2e-459b-b799-ef0e7b1e0f10",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "scanneddatetime",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "7671a8d8-6f69-484f-b1bc-87391997f86d",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "to"
            },
            "RangeMinimumValue": {
              "Parameter": "from"
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
              "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "443a98db-049e-449c-9e24-9430f334f940",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "Column": {
              "ColumnName": "Omzet last Year",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "c0d5dbbc-93fe-4226-ab0d-cdc392251070",
            "MatchOperator": "DOES_NOT_EQUAL",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 0
          }
        },
        {
          "NumericEqualityFilter": {
            "AggregationFunction": {
              "NumericalAggregationFunction": {
                "SimpleNumericalAggregation": "SUM"
              }
            },
            "Column": {
              "ColumnName": "(opbrengsten) Grafiek 1",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "c0c29cca-14d9-4e29-b119-d8a13e4c580d",
            "MatchOperator": "DOES_NOT_EQUAL",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 0
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8",
              "VisualIds": [
                "9835e990-989f-43b1-a59f-4f4d3d07332c"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ecae529a-8d33-447c-ab34-6225a392208a",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "Column": {
              "ColumnName": "Omzet last Year",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "0ed66e39-ffdc-476f-ad66-8813f35f1640",
            "MatchOperator": "DOES_NOT_EQUAL",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 0
          }
        },
        {
          "NumericEqualityFilter": {
            "AggregationFunction": {
              "NumericalAggregationFunction": {
                "SimpleNumericalAggregation": "SUM"
              }
            },
            "Column": {
              "ColumnName": "(opbrengsten) Grafiek 1",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "58255a08-9f84-4123-a537-919e406abba6",
            "MatchOperator": "DOES_NOT_EQUAL",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 0
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8",
              "VisualIds": [
                "e6855a84-b673-4f40-8db3-c48eda6574d8"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "6ce25d68-3b55-460b-aff6-2c41379bbfe7",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "workshiftid",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Selectedparameter"
              }
            },
            "FilterId": "5d6a5fa6-467a-40db-bb7e-12f28f3c228d"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "36caa6ca-4e2f-4c02-b245-eaf5de88305c",
              "VisualIds": [
                "ecee5303-d8ad-4277-b6f0-2bd786247d65"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "47a0c9a0-72af-43d3-9bd1-de658f0733a5",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Month",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "e484db02-1937-4477-b8ce-f5975fa0ec83"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "ALL_DATASETS",
      "FilterGroupId": "99121df0-a8a6-4d48-95c6-58bfd9c91373",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "workshiftactualended",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "d56be041-6190-4a89-b6f8-ba72e1baf899",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "to"
            },
            "RangeMinimumValue": {
              "Parameter": "from"
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
              "SheetId": "0f0edfa3-2438-4684-8b82-f4a91f4661a4",
              "VisualIds": [
                "a946457c-f6c1-4140-961a-7cc8f2ce0922",
                "5c8f9311-18aa-4490-8898-8ad450692869",
                "d11654e3-2321-4514-8989-a2bc1193b42b",
                "4da2ed15-5e42-46b7-9c14-045639f1c6c9"
              ]
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "be0b7ba8-c2c0-4205-8e0e-c9319dadeea6",
      "Filters": [
        {
          "NumericEqualityFilter": {
            "Column": {
              "ColumnName": "Omzet last Year",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "74d76617-9b94-4060-bfc2-70596a30cacc",
            "MatchOperator": "DOES_NOT_EQUAL",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 0
          }
        },
        {
          "NumericEqualityFilter": {
            "AggregationFunction": {
              "NumericalAggregationFunction": {
                "SimpleNumericalAggregation": "SUM"
              }
            },
            "Column": {
              "ColumnName": "(opbrengsten) Grafiek 1",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "3cc7dac7-fba9-4ebc-9b01-dcbc6f06a2d7",
            "MatchOperator": "DOES_NOT_EQUAL",
            "NullOption": "NON_NULLS_ONLY",
            "Value": 0
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8",
              "VisualIds": [
                "6d11dd67-b214-4735-b135-3dbbc47224f2"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "cb25eea0-d3de-4cdd-9371-b32b26a7f47a",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "endreason",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Endreason"
              }
            },
            "FilterId": "04c70c73-5a1e-49b2-b224-6f964168a4fb"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "0cf6c09a-6cd5-4b7e-8f0e-ebc66f0682de",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "f90baf94-a3d4-4d43-a1f8-40f0883d5ea8"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "16560584-9364-4e14-aeb3-95e9ffc3507b",
      "Filters": [
        {
          "TimeRangeFilter": {
            "Column": {
              "ColumnName": "started",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "FilterId": "290ecdd8-50e9-4a7e-a941-02c2f0d64586",
            "IncludeMaximum": true,
            "IncludeMinimum": true,
            "NullOption": "NON_NULLS_ONLY",
            "RangeMaximumValue": {
              "Parameter": "to"
            },
            "RangeMinimumValue": {
              "Parameter": "from"
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
              "SheetId": "5e34bd0d-ce5e-4f35-8514-f347c60c8262"
            },
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "ed10dba4-fc18-4d50-a094-687a1bfcbb14"
            },
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "7b354836-d5fa-4e98-bd6d-cc660e4b85cf"
            },
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "36caa6ca-4e2f-4c02-b245-eaf5de88305c"
            },
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8"
            },
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e"
            }
          ]
        }
      },
      "Status": "DISABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "3b19df29-de0b-49fd-8b9f-2e828d4b64a4",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "37e73c91-9504-44e8-b1aa-ab4613940356"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "f41b0558-e5be-4827-ab7e-793ac82badfb",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "endreason",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "d1f3984a-c461-42af-8cab-a3663d6aba05"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "36caa6ca-4e2f-4c02-b245-eaf5de88305c",
              "VisualIds": [
                "ecee5303-d8ad-4277-b6f0-2bd786247d65"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "ae6830de-e2e8-477d-81c6-968bddf97a9b",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Year",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "CONTAINS",
                "NullOption": "NON_NULLS_ONLY",
                "SelectAllOptions": "FILTER_ALL_VALUES"
              }
            },
            "FilterId": "bc2723db-54fc-4983-ba0f-eeecd3bae5d7"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "5213a02a-e1f7-4d22-986b-ff6d7003241f",
      "Filters": [
        {
          "NumericRangeFilter": {
            "Column": {
              "ColumnName": "distancetocheckpointlocation",
              "DataSetIdentifier": "sequrix_planning_records"
            },
            "FilterId": "c09b75b0-efdc-4532-a023-ef4988b2b0eb",
            "IncludeMaximum": false,
            "IncludeMinimum": true,
            "NullOption": "ALL_VALUES",
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
              "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "9ec57299-e7ba-4499-b71d-a37e2c30ee15",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "regionname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Regio"
              }
            },
            "FilterId": "3c516b84-74fb-4827-9497-4034e93d1503"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0f0edfa3-2438-4684-8b82-f4a91f4661a4"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "2ea59274-1fd0-4dd3-ae1e-42c5fac2bbc6",
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
            "FilterId": "11374b1d-4e32-4fe6-8b86-432bd9bee39a"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "0f0edfa3-2438-4684-8b82-f4a91f4661a4",
              "VisualIds": [
                "4da2ed15-5e42-46b7-9c14-045639f1c6c9",
                "5c8f9311-18aa-4490-8898-8ad450692869",
                "a946457c-f6c1-4140-961a-7cc8f2ce0922"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "a0f9f195-f071-4c9b-a205-0f2f3efcdd7d",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "aansluitingen",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "DOES_NOT_CONTAIN",
                "NullOption": "ALL_VALUES"
              }
            },
            "FilterId": "dbfc2d01-34d6-4b2a-8bc5-484d464e29a5"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "ed10dba4-fc18-4d50-a094-687a1bfcbb14",
              "VisualIds": [
                "755fd895-4fae-4a06-805b-143a951f459c"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "0c949287-055b-4d68-b809-3a75ed15b0bb",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "Medewerkers",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "FilterListConfiguration": {
                "MatchOperator": "DOES_NOT_CONTAIN",
                "NullOption": "ALL_VALUES"
              }
            },
            "FilterId": "57358e79-9156-49f7-91ac-f61973d90f6e"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "SELECTED_VISUALS",
              "SheetId": "7b354836-d5fa-4e98-bd6d-cc660e4b85cf",
              "VisualIds": [
                "3903172b-8eb1-4d60-804b-9f813bdbe882"
              ]
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "a05ed9e0-e501-45a1-824a-3c83141d8f74",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "objectname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "object"
              }
            },
            "FilterId": "74354860-97f4-426c-9f91-94fb993629d9"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "a0890426-3869-47d0-b577-dd9d967c6cf8",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "customername",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "klanten"
              }
            },
            "FilterId": "7ddbb379-73ab-47b7-8fa4-c0b4ccbc2c08"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "730a8225-e768-4665-8d18-ad7175153f08",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "regionname",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Regio"
              }
            },
            "FilterId": "99278516-60df-402d-ad03-5b47a8e25c70"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "85947055-2df6-4716-a139-ef8032cd2844",
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
            "FilterId": "3ac23713-5e0a-4fda-8a34-900031e06afa"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "808fa730-fd2b-4196-9267-0a3d112348ce",
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
            "FilterId": "90c126c8-5cd5-4dee-b907-8d201084a097"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "f69306f6-34cb-48bc-9cd1-7f73ee3fd9a3",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Filtermedewerker"
              }
            },
            "FilterId": "e335797e-13db-4f40-8441-ea280a37a61b"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "7b354836-d5fa-4e98-bd6d-cc660e4b85cf"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "d075e368-c058-41cd-8c72-fcfc7768f13d",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "employee",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Filtermedewerker"
              }
            },
            "FilterId": "396ef3e3-d55f-414e-89a7-4a9fed729095"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0f0edfa3-2438-4684-8b82-f4a91f4661a4"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "391389b0-cb2a-47a7-8312-68c66300e475",
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
            "FilterId": "b5487b96-f43c-4b74-a272-4a9ec0623adc"
          }
        }
      ],
      "ScopeConfiguration": {
        "SelectedSheets": {
          "SheetVisualScopingConfigurations": [
            {
              "Scope": "ALL_VISUALS",
              "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8"
            }
          ]
        }
      },
      "Status": "ENABLED"
    },
    {
      "CrossDataset": "SINGLE_DATASET",
      "FilterGroupId": "b97935e1-4779-49c1-9c03-7a792a77a1a3",
      "Filters": [
        {
          "CategoryFilter": {
            "Column": {
              "ColumnName": "workshifttype",
              "DataSetIdentifier": "sequrix_tasks_records"
            },
            "Configuration": {
              "CustomFilterConfiguration": {
                "MatchOperator": "EQUALS",
                "NullOption": "NON_NULLS_ONLY",
                "ParameterName": "Workshifttype"
              }
            },
            "FilterId": "9ec6bb7a-b131-4ebc-aa19-76b659b21222"
          }
        }
      ],
      "ScopeConfiguration": {
        "AllSheets": {}
      },
      "Status": "ENABLED"
    }
  ],
  "Options": {
    "CustomActionDefaults": {
      "highlightOperation": {
        "Trigger": "NONE"
      }
    },
    "QBusinessInsightsStatus": "DISABLED"
  },
  "ParameterDeclarations": [
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            75329
          ]
        },
        "Name": "Selectedparameter",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            10
          ]
        },
        "Name": "Margestarttimetask",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            5
          ]
        },
        "Name": "Margendtimetask",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            10
          ]
        },
        "Name": "Margestartshift",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            15
          ]
        },
        "Name": "Margeendshift",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            10
          ]
        },
        "Name": "Traveltime",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            85
          ]
        },
        "Name": "Productiviteitsverlies",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            5
          ]
        },
        "Name": "margeDuurTaakTekort",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            10
          ]
        },
        "Name": "margeDuurTaakTeLang",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "IntegerParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            30
          ]
        },
        "Name": "MinimaleTravellimit",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
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
        "DefaultValues": {},
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
        "DefaultValues": {
          "StaticValues": [
            "Overschreden Aanrijtijden"
          ]
        },
        "Name": "Selectie",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Overschreden Aanrijtijden"
          ]
        },
        "Name": "Medewerker",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Risicoadressen"
          ]
        },
        "Name": "ControlAansluiting",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Medewerkers"
          ]
        },
        "Name": "ControlMedewerker",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Diensten"
          ]
        },
        "Name": "ControlAanrijtijden",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "klanten",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "Regio",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Totale Omzet"
          ]
        },
        "Name": "Opbrengsten",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Diensten"
          ]
        },
        "Name": "ControlOpbrengsten",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": []
        },
        "Name": "enableDateSelectionPresets",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "3. Maand"
          ]
        },
        "Name": "dateSelectionAggregation",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "Endreason",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "Workshifttype",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {},
        "Name": "Filtermedewerker",
        "ParameterValueType": "MULTI_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Overschreden Aanrijtijden"
          ]
        },
        "Name": "StatiscsAantal",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Object"
          ]
        },
        "Name": "scansselect",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Aantal handmatig gescand"
          ]
        },
        "Name": "Scandata",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "StringParameterDeclaration": {
        "DefaultValues": {
          "StaticValues": [
            "Overschreden Aanrijtijden"
          ]
        },
        "Name": "Statiscspercentage",
        "ParameterValueType": "SINGLE_VALUED",
        "ValueWhenUnset": {
          "ValueWhenUnsetOption": "RECOMMENDED_VALUE"
        }
      }
    },
    {
      "DateTimeParameterDeclaration": {
        "DefaultValues": {
          "RollingDate": {
            "Expression": "addDateTime(-1, 'YYYY', truncDate('YYYY', now()))"
          },
          "StaticValues": []
        },
        "Name": "from",
        "TimeGranularity": "DAY"
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
        "Name": "to",
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
                  "OptimizedViewPortWidth": "1600px",
                  "ResizeOption": "FIXED"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 12,
                  "ElementId": "206c02b5-558c-422f-9487-6bf52baf65af",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 12,
                  "ElementId": "c700c3f1-8194-46eb-a977-62518fc81f7d",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 24,
                  "ColumnSpan": 12,
                  "ElementId": "21e1ce23-82ae-43e5-83f2-ca66dad4ab6d",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 18,
                  "ElementId": "59ff0c3b-7ca0-4555-92ab-7660bf1e6d00",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 10
                },
                {
                  "ColumnIndex": 18,
                  "ColumnSpan": 18,
                  "ElementId": "a92f5812-9db1-4aba-b174-5d967fd04f95",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 10
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
            "SourceParameterName": "from",
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
            "SourceParameterName": "to",
            "Title": "End"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnSpan": 2,
                  "ElementId": "9f3bc1a4-e786-4bea-b64a-d5de9c347ef2",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowSpan": 1
                },
                {
                  "ColumnSpan": 2,
                  "ElementId": "42e1d308-c39c-4ccb-bfc9-65928330256f",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "5e34bd0d-ce5e-4f35-8514-f347c60c8262",
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
                "CustomActionId": "e7422edd-733a-4afd-a2d2-3a48b706620f",
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
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  },
                  "RotationAngle": 0
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MONTH",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.1.1696421223718",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM YYYY",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        },
                        "HierarchyId": "92253243-232c-4541-a6df-113185221e6f"
                      }
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
                          "ColumnName": "Traveltime exceeded geef id terug wegen dubble id",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1703856858625"
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
                "Width": "120px"
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
                        "FieldId": "2e0a54ef-d4f1-45a2-9268-9c3453fe4ebb.1.1703856858625",
                        "Label": " ",
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
                "GridLineVisibility": "VISIBLE",
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
                  "HierarchyId": "92253243-232c-4541-a6df-113185221e6f"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>Aantal Overschreden Aanrijtijden over tijd</b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "59ff0c3b-7ca0-4555-92ab-7660bf1e6d00"
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
                        "ColumnName": "Uitgevoerd Volgens Rooster ",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.0.1697097571064",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            },
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "NullValueFormatConfiguration": {
                              "NullString": "null"
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
                "TrendArrows": {
                  "Visibility": "HIDDEN"
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
                "RichText": "<visual-title>\n  <block align=\"center\">\n    <inline font-size=\"16px\">\n      <b>Uitgevoerd Volgens Rooster </b>\n    </inline>\n  </block>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "21e1ce23-82ae-43e5-83f2-ca66dad4ab6d"
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
                        "ColumnName": "Uitvoering Binnen Tijdslimit",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.0.1697097435852",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            },
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "NullValueFormatConfiguration": {
                              "NullString": "null"
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
                "TrendArrows": {
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
                "RichText": "<visual-title>\n  <block align=\"center\">\n    <inline font-size=\"16px\">\n      <b>Uitvoering Binnen Tijdslimit</b>\n    </inline>\n  </block>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "c700c3f1-8194-46eb-a977-62518fc81f7d"
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
                        "ColumnName": "stefan - persentage overschreden traveltime",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "220121b0-bd45-4786-b427-c97b61e3263e.1.1702367677241"
                    }
                  }
                ]
              },
              "KPIOptions": {
                "Comparison": {
                  "ComparisonMethod": "DIFFERENCE"
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "ProgressBar": {
                  "Visibility": "HIDDEN"
                },
                "SecondaryValue": {
                  "Visibility": "HIDDEN"
                },
                "SecondaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
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
              "SortConfiguration": {}
            },
            "ColumnHierarchies": [],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <block align=\"center\">\n    <inline font-size=\"16px\">\n      <b>Aantal Overschreden Aanrijtijden</b>\n    </inline>\n  </block>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "206c02b5-558c-422f-9487-6bf52baf65af"
          }
        },
        {
          "BarChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
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
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MONTH",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713788928941",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM YYYY",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        },
                        "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713788928941"
                      }
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
                          "ColumnName": "Parameter workshift_delay_check",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "2e5d18b7-5700-433f-a3ba-32bf33765e3c.1.1713788922716"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "parameter workshift_start_delay_check",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "381bcf92-d9e9-4b00-a8ed-26b537822d51.0.1713788920546"
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
              "Orientation": "VERTICAL",
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713788928941"
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
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713788928941",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "381bcf92-d9e9-4b00-a8ed-26b537822d51.0.1713788920546",
                        "Label": "Te laat Begonnen",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "2e5d18b7-5700-433f-a3ba-32bf33765e3c.1.1713788922716",
                        "Label": "Te Vroeg Gestopt",
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
                  "HierarchyId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713788928941"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>Aantal Diensten Te laat Gestart/Te Vroeg Gestopt</b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "a92f5812-9db1-4aba-b174-5d967fd04f95"
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
                  "OptimizedViewPortWidth": "1600px",
                  "ResizeOption": "FIXED"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "afb429ea-53ec-42fe-8d00-816a190d5881",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 6,
                  "ElementId": "87143081-6c2d-49a5-84f3-50289a64753a",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 24,
                  "ElementId": "13648649-29e3-4321-8d9d-4d38ca932056",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 12,
                  "ElementId": "72b3d95d-b2d0-4985-8b99-203b8cfb0e09",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 12
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 24,
                  "ElementId": "bb144cef-1136-47be-8774-82c5b084f7e2",
                  "ElementType": "VISUAL",
                  "RowIndex": 8,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "755fd895-4fae-4a06-805b-143a951f459c",
                  "ElementType": "VISUAL",
                  "RowIndex": 16,
                  "RowSpan": 15
                }
              ]
            }
          }
        }
      ],
      "Name": "Risico-adres",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "6d6f45ae-421e-4a6e-9c92-404ee61ed300",
            "SourceParameterName": "from",
            "Title": "Van"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "49344d47-1e24-467f-8ec0-80a20b6181d9",
            "SourceParameterName": "to",
            "Title": "Tot"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "afb429ea-53ec-42fe-8d00-816a190d5881",
            "SelectableValues": {
              "Values": [
                "Alarmopvolgingen",
                "Overschreden Aanrijtijden",
                "Taken Uitgevoerd Buiten Rooster",
                "Taken Uitgevoerd Buiten Tijdslimiet",
                "Totaal Aantal Taken Afgerond"
              ]
            },
            "SourceParameterName": "Selectie",
            "Title": "selectie",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "87143081-6c2d-49a5-84f3-50289a64753a",
            "SelectableValues": {
              "Values": [
                "Alarmtype",
                "Dienstenverlening",
                "Eindreden",
                "Klanten",
                "Prio",
                "Risicoadressen"
              ]
            },
            "SourceParameterName": "ControlAansluiting",
            "Title": "Filter",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
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
            "ParameterControlId": "e2d277a2-e721-4f19-ad03-79dac3b94547",
            "SelectableValues": {
              "Values": [
                "1. Dag",
                "2. Week",
                "3. Maand",
                "4. Kwartaal",
                "5. Jaar"
              ]
            },
            "SourceParameterName": "dateSelectionAggregation",
            "Title": "Interval",
            "Type": "SINGLE_SELECT"
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
            "ParameterControlId": "623b863c-05a8-4c38-842e-da8d1c51cf98",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "objectname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "object",
            "Title": "Risico-adres",
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
            "ParameterControlId": "1bf8865c-bb20-454e-820e-cf188b36e26d",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "customername",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "klanten",
            "Title": "Klanten",
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
            "ParameterControlId": "8c56ba4b-d9e7-4d14-9c72-eefc65cd355b",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "regionname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Regio",
            "Title": "Regio",
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
            "ParameterControlId": "b9d38a17-1f6a-4803-b464-322c0e153e2e",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype prio",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmprio",
            "Title": "Prio",
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
            "ParameterControlId": "e66d1d85-3038-49e3-9ab5-589e2a14398c",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "endreason",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Endreason",
            "Title": "Eindreden",
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
            "ParameterControlId": "9c14a802-3bae-47b2-823f-7b3378e98df2",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "workshifttype",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Workshifttype",
            "Title": "Diensttype",
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
            "ParameterControlId": "ea9e05aa-1bf8-48b1-965d-7255a98c583a",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "productname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "productname",
            "Title": "Dienstverlening",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "e2d277a2-e721-4f19-ad03-79dac3b94547",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "6d6f45ae-421e-4a6e-9c92-404ee61ed300",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "49344d47-1e24-467f-8ec0-80a20b6181d9",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "623b863c-05a8-4c38-842e-da8d1c51cf98",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "1bf8865c-bb20-454e-820e-cf188b36e26d",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 2,
                  "ElementId": "8c56ba4b-d9e7-4d14-9c72-eefc65cd355b",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "ea9e05aa-1bf8-48b1-965d-7255a98c583a",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "b9d38a17-1f6a-4803-b464-322c0e153e2e",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "e66d1d85-3038-49e3-9ab5-589e2a14398c",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "9c14a802-3bae-47b2-823f-7b3378e98df2",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "ed10dba4-fc18-4d50-a094-687a1bfcbb14",
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
                "CustomActionId": "f1d202cf-0497-4e43-80f3-dd18e25b5032",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "<<$Selectie>>",
                    "FieldId": "cfff8697-03e8-42d9-b8d5-91151e574e01.2.1712565562895",
                    "Width": "294px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "059a1969-1cb7-4882-b2f4-9a18605a74aa.1.1711380059926",
                    "Width": "91px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "c6c652d7-a726-46ff-b1b7-9a9847b329f9.2.1711380062081",
                    "Width": "74px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "(aansluiting) Table ",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "cfff8697-03e8-42d9-b8d5-91151e574e01.2.1712565562895"
                      }
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(aansluitingen) selectie grafiek 1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "059a1969-1cb7-4882-b2f4-9a18605a74aa.1.1711380059926"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(Aanslutingen) selectie grafiek 2",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c6c652d7-a726-46ff-b1b7-9a9847b329f9.2.1711380062081",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                "PaginationConfiguration": {
                  "PageNumber": 1,
                  "PageSize": 500
                },
                "RowSort": [
                  {
                    "FieldSort": {
                      "Direction": "DESC",
                      "FieldId": "059a1969-1cb7-4882-b2f4-9a18605a74aa.1.1711380059926"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 32
                },
                "HeaderStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 30,
                  "TextWrap": "WRAP"
                },
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitvoering Binnen Tijdslimit % Per Object</visual-title>"
              },
              "Visibility": "HIDDEN"
            },
            "VisualId": "72b3d95d-b2d0-4985-8b99-203b8cfb0e09"
          }
        },
        {
          "ComboChartVisual": {
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
                "CustomActionId": "73908e1c-462b-424a-858d-6038c2f0dbd7",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarDataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "DataOptions": {
                  "DateAxisOptions": {
                    "MissingDateVisibility": "HIDDEN"
                  }
                },
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "ComboChartAggregatedFieldWells": {
                  "BarValues": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(aansluitingen) selectie grafiek 1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "059a1969-1cb7-4882-b2f4-9a18605a74aa.1.1711370993487",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  ],
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1731570266855",
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1731570266855"
                      }
                    }
                  ],
                  "Colors": [],
                  "LineValues": []
                }
              },
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "120px"
              },
              "LineDataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "HIDDEN"
              },
              "PrimaryYAxisDisplayOptions": {
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "PrimaryYAxisLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "SingleAxisOptions": {
                "YAxisOptions": {
                  "YAxis": "PRIMARY_Y_AXIS"
                }
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1731570266855"
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
                        "FieldId": "059a1969-1cb7-4882-b2f4-9a18605a74aa.1.1711370993487",
                        "Label": "Aantal",
                        "TooltipTarget": "BAR",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1731570266855",
                        "TooltipTarget": "BOTH",
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1731570266855"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>\n      <parameter>$${Selectie}</parameter>\n    </b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "13648649-29e3-4321-8d9d-4d38ca932056"
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
                "CustomActionId": "14bb2376-48c0-4cfe-b245-18322384ab70",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "ID",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214",
                    "Width": "95px"
                  },
                  {
                    "CustomLabel": "Risico-adres",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057",
                    "Width": "233px"
                  },
                  {
                    "CustomLabel": "Dienstverlening",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171",
                    "Width": "184px"
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "Width": "153px"
                  },
                  {
                    "CustomLabel": "Geplande Starttijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123",
                    "Width": "143px"
                  },
                  {
                    "CustomLabel": "Gestart",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                    "Width": "174px"
                  },
                  {
                    "CustomLabel": "Gestopt",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                    "Width": "148px"
                  },
                  {
                    "CustomLabel": "Geplande eindtijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905",
                    "Width": "142px"
                  },
                  {
                    "CustomLabel": "Duur",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.10.1702318352766",
                    "Width": "89px"
                  },
                  {
                    "CustomLabel": "Daadwerkelijke duur",
                    "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                    "Width": "154px"
                  },
                  {
                    "CustomLabel": "Beschrijving",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.description.11.1702367927854",
                    "Width": "392px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockstarttime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockendtime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duration",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.10.1702318352766"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duur_werkzaamheden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "description",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.description.11.1702367927854"
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
                }
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "SideSpecificBorder": {
                      "InnerHorizontal": {
                        "Style": "SOLID"
                      }
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 34,
                  "HorizontalTextAlignment": "LEFT",
                  "TextWrap": "WRAP",
                  "VerticalTextAlignment": "BOTTOM"
                },
                "HeaderStyle": {
                  "Border": {
                    "SideSpecificBorder": {
                      "InnerHorizontal": {
                        "Style": "SOLID",
                        "Thickness": 2
                      }
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 37,
                  "HorizontalTextAlignment": "LEFT",
                  "TextWrap": "WRAP",
                  "VerticalTextAlignment": "BOTTOM",
                  "Visibility": "VISIBLE"
                },
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
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
                          "Color": "#4A90E2",
                          "Expression": "{Uitvoering Binnen Tijdslimit} = 0"
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
                          "Color": "#4A90E2",
                          "Expression": "SUM({taak te laat uitgevoerd}) > 1"
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
                          "Color": "#4A90E2",
                          "Expression": "SUM({taak te vroeg begonnen}) < -1"
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
                          "Color": "#4A90E2",
                          "Expression": "DISTINCT_COUNT({Traveltime exceeded geef id terug wegen dubble id}) = 1"
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
            "VisualId": "755fd895-4fae-4a06-805b-143a951f459c"
          }
        },
        {
          "ComboChartVisual": {
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
                "CustomActionId": "5d9ad9c3-d915-42ff-8996-5546549c5949",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarDataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "SMALL"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "BarsArrangement": "CLUSTERED",
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
              "FieldWells": {
                "ComboChartAggregatedFieldWells": {
                  "BarValues": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(Aanslutingen) selectie grafiek 2",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c6c652d7-a726-46ff-b1b7-9a9847b329f9.1.1711373211923",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                  ],
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616",
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616"
                      }
                    }
                  ],
                  "Colors": [],
                  "LineValues": []
                }
              },
              "Legend": {
                "Height": "39px",
                "Position": "TOP",
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "120px"
              },
              "LineDataLabels": {
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "PrimaryYAxisDisplayOptions": {
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "PrimaryYAxisLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "SingleAxisOptions": {
                "YAxisOptions": {
                  "YAxis": "PRIMARY_Y_AXIS"
                }
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616"
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
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616",
                        "TooltipTarget": "BOTH",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "c6c652d7-a726-46ff-b1b7-9a9847b329f9.1.1711373211923",
                        "Label": "Percentage",
                        "TooltipTarget": "BAR",
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>Percentage </b>\n  </inline>\n  <inline font-size=\"16px\">\n    <b>\n      <parameter>$${Selectie}</parameter>\n    </b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "bb144cef-1136-47be-8774-82c5b084f7e2"
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
                  "OptimizedViewPortWidth": "1600px",
                  "ResizeOption": "FIXED"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 7,
                  "ElementId": "fd92b302-66ea-4a26-ba08-9908d6ce08fd",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 7,
                  "ColumnSpan": 5,
                  "ElementId": "2b7459f1-3e01-4140-bdb1-7c612314f85a",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 24,
                  "ElementId": "d0103c95-c6fb-490d-87b2-e28197e7d79c",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 12,
                  "ElementId": "ff5188a2-8613-4057-9188-6e73a47644e0",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 12
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 24,
                  "ElementId": "acb2682d-88f4-4da5-845a-cb7b3a468cc5",
                  "ElementType": "VISUAL",
                  "RowIndex": 8,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "3903172b-8eb1-4d60-804b-9f813bdbe882",
                  "ElementType": "VISUAL",
                  "RowIndex": 16,
                  "RowSpan": 14
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
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "de37c238-ec1a-437c-a1f0-b6d548866e40",
            "SourceParameterName": "from",
            "Title": "Van"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "c2ce68de-cff7-41d9-a5f7-6c4de7346ef2",
            "SourceParameterName": "to",
            "Title": "Tot"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "fd92b302-66ea-4a26-ba08-9908d6ce08fd",
            "SelectableValues": {
              "Values": [
                "Diensten Te laat begonnen",
                "Diensten Vroegtijdig Beëindigd",
                "Overschreden Aanrijtijden",
                "Taken Uitgevoerd Buiten Rooster",
                "Taken Uitgevoerd Buiten Tijdslimiet"
              ]
            },
            "SourceParameterName": "Medewerker",
            "Title": "test",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "2b7459f1-3e01-4140-bdb1-7c612314f85a",
            "SelectableValues": {
              "Values": [
                "Dienstenverlening",
                "Medewerkers"
              ]
            },
            "SourceParameterName": "ControlMedewerker",
            "Title": "Filter",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
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
            "ParameterControlId": "11c25b9b-1745-4558-8b90-7c3834909b73",
            "SelectableValues": {
              "Values": [
                "1. Dag",
                "2. Week",
                "3. Maand",
                "4. Kwartaal",
                "5. Jaar"
              ]
            },
            "SourceParameterName": "dateSelectionAggregation",
            "Title": "Interval",
            "Type": "SINGLE_SELECT"
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
            "ParameterControlId": "74f93ebf-8e93-44e2-9e4f-114f08e68774",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "customername",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "klanten",
            "Title": "Klanten",
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
            "ParameterControlId": "0b23256e-b80c-4f6f-8e5b-86811ca68f96",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "objectname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "object",
            "Title": "Risico-adres",
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
            "ParameterControlId": "a035213a-4030-439f-b814-2ea69f57aa6e",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "regionname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Regio",
            "Title": "Regio",
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
            "ParameterControlId": "929a0555-fcc9-4e22-bfae-76deb17a4081",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype prio",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmprio",
            "Title": "Prio",
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
            "ParameterControlId": "1d437231-f06c-495d-be33-882c3ca6fd61",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "endreason",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Endreason",
            "Title": "Eindreden",
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
            "ParameterControlId": "a1a009f5-60c7-4636-893c-de8de288204a",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "workshifttype",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Workshifttype",
            "Title": "Diensttype",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "CommitMode": "AUTO",
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
            "ParameterControlId": "77a74b07-d44e-44b6-a34b-92fc99e25546",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "employee",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Filtermedewerker",
            "Title": "Medewerker",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Dropdown": {
            "CommitMode": "AUTO",
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
            "ParameterControlId": "9e5c8bb5-0872-43a1-8c78-cf6d7c71cd6f",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "productname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "productname",
            "Title": "Dienstverlening",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "11c25b9b-1745-4558-8b90-7c3834909b73",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "de37c238-ec1a-437c-a1f0-b6d548866e40",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "c2ce68de-cff7-41d9-a5f7-6c4de7346ef2",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "0b23256e-b80c-4f6f-8e5b-86811ca68f96",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "74f93ebf-8e93-44e2-9e4f-114f08e68774",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 2,
                  "ElementId": "a035213a-4030-439f-b814-2ea69f57aa6e",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "9e5c8bb5-0872-43a1-8c78-cf6d7c71cd6f",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "929a0555-fcc9-4e22-bfae-76deb17a4081",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "1d437231-f06c-495d-be33-882c3ca6fd61",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "a1a009f5-60c7-4636-893c-de8de288204a",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "77a74b07-d44e-44b6-a34b-92fc99e25546",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "7b354836-d5fa-4e98-bd6d-cc660e4b85cf",
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
                "CustomActionId": "6276476a-81c3-4611-bda2-e9235dae6fbd",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "ID",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214",
                    "Width": "99px"
                  },
                  {
                    "CustomLabel": "<<$ControlMedewerker>>",
                    "FieldId": "8498d908-5354-4fcb-8cb2-dc91fc68a303.11.1712686789797",
                    "Width": "257px"
                  },
                  {
                    "CustomLabel": "Risico-adres",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057",
                    "Width": "217px"
                  },
                  {
                    "CustomLabel": "Dienstverlening",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171",
                    "Width": "184px"
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811",
                    "Width": "153px"
                  },
                  {
                    "CustomLabel": "Geplande Starttijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123",
                    "Width": "143px"
                  },
                  {
                    "CustomLabel": "Gestart",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811",
                    "Width": "174px"
                  },
                  {
                    "CustomLabel": "Gestopt",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660",
                    "Width": "148px"
                  },
                  {
                    "CustomLabel": "Geplande Eindtijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905",
                    "Width": "142px"
                  },
                  {
                    "CustomLabel": "Duur",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.10.1702318352766",
                    "Width": "89px"
                  },
                  {
                    "CustomLabel": "Daadwerkelijke duur",
                    "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781",
                    "Width": "154px"
                  },
                  {
                    "CustomLabel": "Beschrijving",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.description.11.1702367927854",
                    "Width": "330px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.taskid.10.1698671930214"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "(medewerkers) Table",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "8498d908-5354-4fcb-8cb2-dc91fc68a303.11.1712686789797"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.11.1698671880057"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.8.1698672129171"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1698672160811"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockstarttime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockstarttime.11.1698674933123"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.9.1698673644811"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.10.1698673666660"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "blockendtime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.blockendtime.10.1698674930905"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duration",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.10.1702318352766"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "duur_werkzaamheden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "684d7587-6e29-4414-bfc1-dc512deeda30.13.1698745443781"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "description",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.description.11.1702367927854"
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
                  "Border": {
                    "SideSpecificBorder": {
                      "InnerHorizontal": {
                        "Style": "SOLID"
                      }
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 36,
                  "HorizontalTextAlignment": "LEFT",
                  "TextWrap": "WRAP",
                  "VerticalTextAlignment": "BOTTOM"
                },
                "HeaderStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "NONE",
                      "Thickness": 2
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 37,
                  "HorizontalTextAlignment": "LEFT",
                  "TextWrap": "WRAP",
                  "VerticalTextAlignment": "BOTTOM"
                },
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
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
                          "Color": "#4A90E2",
                          "Expression": "{Uitvoering Binnen Tijdslimit} = 0"
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
                          "Color": "#4A90E2",
                          "Expression": "SUM({taak te laat uitgevoerd}) > 5"
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
                          "Color": "#4A90E2",
                          "Expression": "SUM({taak te vroeg begonnen}) < -10"
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
                          "Color": "#4A90E2",
                          "Expression": "DISTINCT_COUNT({Traveltime exceeded geef id terug wegen dubble id}) = 1"
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
            "VisualId": "3903172b-8eb1-4d60-804b-9f813bdbe882"
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
                "CustomActionId": "65e41c0f-525c-4e54-8307-c04e886143da",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "<<$Medewerker>>",
                    "FieldId": "8498d908-5354-4fcb-8cb2-dc91fc68a303.2.1712565944204",
                    "Width": "269px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "78a34943-1e8f-4871-a7eb-5c3fdbd711b2.2.1712564908025",
                    "Width": "105px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "6ba492ba-662f-4cb2-9b34-54c8f239a1c7.2.1712564910117",
                    "Width": "99px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "(medewerkers) Table",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "8498d908-5354-4fcb-8cb2-dc91fc68a303.2.1712565944204"
                      }
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(Medewerkers) grafiek 1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "78a34943-1e8f-4871-a7eb-5c3fdbd711b2.2.1712564908025"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(Medewerkers) Grafiek 2",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "6ba492ba-662f-4cb2-9b34-54c8f239a1c7.2.1712564910117",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                      "Direction": "DESC",
                      "FieldId": "78a34943-1e8f-4871-a7eb-5c3fdbd711b2.2.1712564908025"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 31
                },
                "HeaderStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 34,
                  "TextWrap": "WRAP"
                },
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
                }
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Uitvoering Binnen Tijdslimit % Per Object</visual-title>"
              },
              "Visibility": "HIDDEN"
            },
            "VisualId": "ff5188a2-8613-4057-9188-6e73a47644e0"
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
                "CustomActionId": "10ee48d9-b93e-44dc-8623-dc58c5c6469a",
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
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "FormatConfiguration": {
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        },
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                      }
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(Medewerkers) grafiek 1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "78a34943-1e8f-4871-a7eb-5c3fdbd711b2.1.1712516255836",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
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
              "Legend": {
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "120px"
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
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
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
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "78a34943-1e8f-4871-a7eb-5c3fdbd711b2.1.1712516255836",
                        "Label": "Aantal",
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
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>\n      <parameter>$${Medewerker}</parameter>\n    </b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "d0103c95-c6fb-490d-87b2-e28197e7d79c"
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
                "CustomActionId": "6fce1775-f481-4e7f-9b7b-d18291b4c212",
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
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616",
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616"
                      }
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "(Medewerkers) Grafiek 2",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "6ba492ba-662f-4cb2-9b34-54c8f239a1c7.1.1712516258896",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
              "Legend": {
                "Position": "TOP",
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "VISIBLE",
                "Width": "120px"
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
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616"
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
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "6ba492ba-662f-4cb2-9b34-54c8f239a1c7.1.1712516258896",
                        "Label": "Percentage",
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
                "GridLineVisibility": "VISIBLE",
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.2.1711372988616"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>Percentage </b>\n  </inline>\n  <inline font-size=\"16px\">\n    <b>\n      <parameter>$${Medewerker}</parameter>\n    </b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "acb2682d-88f4-4da5-845a-cb7b3a468cc5"
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
                  "ElementId": "d11654e3-2321-4514-8989-a2bc1193b42b",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 12,
                  "ElementId": "5c8f9311-18aa-4490-8898-8ad450692869",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 24,
                  "ColumnSpan": 12,
                  "ElementId": "a946457c-f6c1-4140-961a-7cc8f2ce0922",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 6
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "4da2ed15-5e42-46b7-9c14-045639f1c6c9",
                  "ElementType": "VISUAL",
                  "RowIndex": 10,
                  "RowSpan": 12
                }
              ]
            }
          }
        }
      ],
      "Name": "Prestatiedashboard",
      "ParameterControls": [
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
            "ParameterControlId": "eaa3c4d3-9fce-4f47-acf2-fc686fe1acf7",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "regionname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Regio",
            "Title": "Regio",
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
            "ParameterControlId": "650dcf58-cff6-4562-8abb-b52c1ecbde1f",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype prio",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmprio",
            "Title": "Prio",
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
            "ParameterControlId": "f54574d3-a8dc-4042-a56e-8d03b03ef668",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "workshifttype",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Workshifttype",
            "Title": "Diensttype",
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
            "ParameterControlId": "f583cf5b-9c56-4750-b6d4-038d9c30e031",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "endreason",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Endreason",
            "Title": "Eindreden",
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
            "ParameterControlId": "b09c8b3d-e9d5-4b02-9115-1a99f379f777",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "employee",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Filtermedewerker",
            "Title": "Medewerker",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "eaa3c4d3-9fce-4f47-acf2-fc686fe1acf7",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "650dcf58-cff6-4562-8abb-b52c1ecbde1f",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "f583cf5b-9c56-4750-b6d4-038d9c30e031",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "f54574d3-a8dc-4042-a56e-8d03b03ef668",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnSpan": 2,
                  "ElementId": "b09c8b3d-e9d5-4b02-9115-1a99f379f777",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "0f0edfa3-2438-4684-8b82-f4a91f4661a4",
      "Visuals": [
        {
          "GaugeChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "ColorConfiguration": {
                "BackgroundColor": "#4A90E2",
                "ForegroundColor": "#DE3B00"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "LARGE"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "TargetValues": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - Uitvoering binnen tijdslimiet 95%",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "fe37424d-0720-452e-8644-d39f2e07aee2.1.1705593792170"
                    }
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "Uitgevoerd Volgens Rooster ",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.0.1697097571064",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            },
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "NullValueFormatConfiguration": {
                              "NullString": "null"
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
              "GaugeChartOptions": {
                "Arc": {
                  "ArcThickness": "LARGE"
                },
                "ArcAxis": {
                  "Range": {
                    "Max": 1,
                    "Min": 0
                  },
                  "ReserveRange": 0
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "PrimaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "LARGE"
                  }
                }
              },
              "TooltipOptions": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.0.1697097571064",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "fe37424d-0720-452e-8644-d39f2e07aee2.1.1705593792170",
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
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Arc": {
                    "ForegroundColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "{Uitgevoerd Volgens Rooster } >= 0.95"
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
                "RichText": "<visual-title>\n  <block align=\"center\">\n    <inline font-size=\"20px\">\n      <b>Volgens Planning</b>\n    </inline>\n  </block>\n  <br/>\n  <block align=\"center\"/>\n  <br/>\n  <block align=\"center\"/>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "a946457c-f6c1-4140-961a-7cc8f2ce0922"
          }
        },
        {
          "GaugeChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "ColorConfiguration": {
                "BackgroundColor": "#4A90E2",
                "ForegroundColor": "#DE3B00"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "TargetValues": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - Uitvoering binnen tijdslimiet 95%",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "fe37424d-0720-452e-8644-d39f2e07aee2.1.1705593529485"
                    }
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "Uitvoering Binnen Tijdslimit",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.0.1697097435852",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            },
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "NullValueFormatConfiguration": {
                              "NullString": "null"
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
              "GaugeChartOptions": {
                "Arc": {
                  "ArcAngle": 180,
                  "ArcThickness": "LARGE"
                },
                "ArcAxis": {
                  "Range": {
                    "Max": 1
                  },
                  "ReserveRange": 0
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "PrimaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "LARGE"
                  }
                }
              },
              "TooltipOptions": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.0.1697097435852",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "fe37424d-0720-452e-8644-d39f2e07aee2.1.1705593529485",
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
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Arc": {
                    "ForegroundColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "{Uitvoering Binnen Tijdslimit} >= 0.95"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <block align=\"center\">\n    <inline font-size=\"20px\">\n      <b>Duur Werkzaamheden</b>\n    </inline>\n  </block>\n  <br/>\n  <block align=\"center\"/>\n  <br/>\n  <block align=\"center\"/>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "5c8f9311-18aa-4490-8898-8ad450692869"
          }
        },
        {
          "GaugeChartVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "ColorConfiguration": {
                "BackgroundColor": "#4A90E2",
                "ForegroundColor": "#DE3B00"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "EXTRA_LARGE"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "TargetValues": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - Uitvoering binnen tijdslimiet 95%",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "e607923f-a386-4bc2-a1ac-de1e413c62c5.1.1706006510689"
                    }
                  }
                ],
                "Values": [
                  {
                    "NumericalMeasureField": {
                      "Column": {
                        "ColumnName": "stefan - prestataiedashboard percentage niet overschreden aantijdtijden",
                        "DataSetIdentifier": "sequrix_tasks_records"
                      },
                      "FieldId": "abb6f495-91f3-47d3-bf0e-d75b9265b938.1.1706005871911",
                      "FormatConfiguration": {
                        "FormatConfiguration": {
                          "PercentageDisplayFormatConfiguration": {
                            "DecimalPlacesConfiguration": {
                              "DecimalPlaces": 0
                            },
                            "NegativeValueConfiguration": {
                              "DisplayMode": "NEGATIVE"
                            },
                            "NullValueFormatConfiguration": {
                              "NullString": "null"
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
              "GaugeChartOptions": {
                "Arc": {
                  "ArcAngle": 180,
                  "ArcThickness": "LARGE"
                },
                "ArcAxis": {
                  "Range": {
                    "Max": 1,
                    "Min": 0
                  },
                  "ReserveRange": 0
                },
                "PrimaryValueDisplayType": "ACTUAL",
                "PrimaryValueFontConfiguration": {
                  "FontSize": {
                    "Relative": "LARGE"
                  }
                }
              },
              "TooltipOptions": {
                "FieldBasedTooltip": {
                  "AggregationVisibility": "HIDDEN",
                  "TooltipFields": [
                    {
                      "FieldTooltipItem": {
                        "FieldId": "abb6f495-91f3-47d3-bf0e-d75b9265b938.1.1706005871911",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e607923f-a386-4bc2-a1ac-de1e413c62c5.1.1706006510689",
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
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Arc": {
                    "ForegroundColor": {
                      "Solid": {
                        "Color": "#2CAD00",
                        "Expression": "{stefan - prestataiedashboard percentage niet overschreden aantijdtijden} >= 0.95"
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <block align=\"center\">\n    <inline font-size=\"20px\">\n      <b>Aanrijdtijden</b>\n    </inline>\n  </block>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "d11654e3-2321-4514-8989-a2bc1193b42b"
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
                "CustomActionId": "30143bdf-f9cc-4c74-9951-61996d4dd3dd",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.0.1696411037393",
                    "Width": "239px"
                  },
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.6.1697007256431",
                    "Width": "176px"
                  },
                  {
                    "CustomLabel": "Start Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                    "Width": "144px"
                  },
                  {
                    "CustomLabel": "Einde Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                    "Width": "142px"
                  },
                  {
                    "CustomLabel": "Gemiddelde Aanrijtijd (min)",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.3.1696412039222",
                    "Width": "205px"
                  },
                  {
                    "CustomLabel": "Overschreden Aanrijtijden",
                    "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.5.1696521167406",
                    "Width": "207px"
                  },
                  {
                    "CustomLabel": "Uitgevoerd Volgens Rooster %",
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                    "Width": "223px"
                  },
                  {
                    "CustomLabel": "Uitvoering Binnen Tijdslimiet %",
                    "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                    "Width": "233px"
                  },
                  {
                    "CustomLabel": "Afgerond",
                    "FieldId": "c36e82d0-ea12-402f-8861-c1bc34463009.2.1696411698251",
                    "Width": "82px"
                  },
                  {
                    "CustomLabel": "Overig",
                    "FieldId": "42bea99a-30e0-42af-9167-630d160bebcf.10.1702300257103"
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
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.0.1696411037393"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.6.1697007256431"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualstarted",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM D, YYYY H:mm",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        }
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM D, YYYY H:mm",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        }
                      }
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
                          "ColumnName": "Uitgevoerd Volgens Rooster ",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                          "ColumnName": "Uitvoering Binnen Tijdslimit",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                          "ColumnName": "afgeronde alarmen",
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
                          "ColumnName": "stefan - Overig",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "42bea99a-30e0-42af-9167-630d160bebcf.10.1702300257103"
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
                  "Border": {
                    "UniformBorder": {
                      "Style": "SOLID",
                      "Thickness": 1
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 38,
                  "HorizontalTextAlignment": "CENTER",
                  "TextWrap": "WRAP"
                },
                "HeaderStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "NONE",
                      "Thickness": 1
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 33,
                  "HorizontalTextAlignment": "CENTER",
                  "TextWrap": "WRAP",
                  "VerticalTextAlignment": "BOTTOM",
                  "Visibility": "VISIBLE"
                },
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
                }
              },
              "TotalOptions": {
                "CustomLabel": "",
                "Placement": "END",
                "ScrollStatus": "SCROLLED",
                "TotalCellStyle": {
                  "BackgroundColor": "#F4F0F0",
                  "Border": {
                    "UniformBorder": {
                      "Color": "#B7B7B7",
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  }
                },
                "TotalsVisibility": "HIDDEN"
              }
            },
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Cell": {
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "{Uitgevoerd Volgens Rooster } <= 0.6"
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
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "{Uitvoering Binnen Tijdslimit} <= 0.6"
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
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "AVG({Workshift te vroeg gestopt}) > 10"
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
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "AVG({Workshift te laat begonnen}) > 10"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "Visibility": "HIDDEN"
            },
            "VisualId": "4da2ed15-5e42-46b7-9c14-045639f1c6c9"
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
                  "OptimizedViewPortWidth": "1600px",
                  "ResizeOption": "FIXED"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "ecee5303-d8ad-4277-b6f0-2bd786247d65",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 7
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "b39574ad-e214-4837-8565-ed8aee7223ff",
                  "ElementType": "VISUAL",
                  "RowIndex": 7,
                  "RowSpan": 12
                }
              ]
            }
          }
        }
      ],
      "Name": " Diensten",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "f792fe2d-75bb-49c1-9e9e-67fe7744fa64",
            "SourceParameterName": "to",
            "Title": "Tot"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "VISIBLE"
              }
            },
            "ParameterControlId": "9b75ca83-1eb8-4b93-b2f7-7554343944d1",
            "SourceParameterName": "from",
            "Title": "Van"
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
            "ParameterControlId": "da5385c1-ca3c-4f8d-8254-1311ccf21f65",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "regionname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Regio",
            "Title": "Regio",
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
            "ParameterControlId": "70cc5e12-7b7a-4068-81d3-e7eb6b43c45d",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype prio",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmprio",
            "Title": "Prio",
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
            "ParameterControlId": "b017d6ce-a707-48f7-a732-c22ae0ded316",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "endreason",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Endreason",
            "Title": "Eindreden",
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
            "ParameterControlId": "757bbdb3-a58f-4b17-b080-e53d52feff04",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "workshifttype",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Workshifttype",
            "Title": "Diensttype",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "9b75ca83-1eb8-4b93-b2f7-7554343944d1",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "f792fe2d-75bb-49c1-9e9e-67fe7744fa64",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "da5385c1-ca3c-4f8d-8254-1311ccf21f65",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnSpan": 2,
                  "ElementId": "70cc5e12-7b7a-4068-81d3-e7eb6b43c45d",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowSpan": 1
                },
                {
                  "ColumnSpan": 2,
                  "ElementId": "b017d6ce-a707-48f7-a732-c22ae0ded316",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowSpan": 1
                },
                {
                  "ColumnSpan": 2,
                  "ElementId": "757bbdb3-a58f-4b17-b080-e53d52feff04",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "36caa6ca-4e2f-4c02-b245-eaf5de88305c",
      "Visuals": [
        {
          "TableVisual": {
            "Actions": [
              {
                "ActionOperations": [
                  {
                    "NavigationOperation": {
                      "LocalNavigationConfiguration": {
                        "TargetSheetId": "36caa6ca-4e2f-4c02-b245-eaf5de88305c"
                      }
                    }
                  },
                  {
                    "SetParametersOperation": {
                      "ParameterValueConfigurations": [
                        {
                          "DestinationParameterName": "Selectedparameter",
                          "Value": {
                            "SourceField": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftid.10.1713438007242"
                          }
                        }
                      ]
                    }
                  }
                ],
                "CustomActionId": "e9ab504e-d852-4779-bd3c-ea678bf579f3",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftid.10.1713438007242",
                    "Visibility": "HIDDEN"
                  },
                  {
                    "CustomLabel": "Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.0.1696411037393",
                    "Width": "239px"
                  },
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.6.1697007256431",
                    "Width": "176px"
                  },
                  {
                    "CustomLabel": "Start Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                    "Width": "144px"
                  },
                  {
                    "CustomLabel": "Einde Dienst",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                    "Width": "142px"
                  },
                  {
                    "FieldId": "21d3a674-1d25-41eb-b508-bf4114d22c08.12.1713439055691",
                    "Visibility": "HIDDEN"
                  },
                  {
                    "CustomLabel": "Gemiddelde Aanrijtijd (min)",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.3.1696412039222",
                    "Width": "205px"
                  },
                  {
                    "CustomLabel": "Overschreden Aanrijtijden",
                    "FieldId": "d66dea8c-5784-4494-8b48-2531d7bc8f0d.5.1696521167406",
                    "Width": "207px"
                  },
                  {
                    "CustomLabel": "Uitgevoerd Volgens Rooster %",
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                    "Width": "223px"
                  },
                  {
                    "CustomLabel": "Uitvoering Binnen Tijdslimiet %",
                    "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                    "Width": "233px"
                  },
                  {
                    "FieldId": "01b6764a-7590-48ed-b83c-58b70bfd8329.11.1713438133531",
                    "Visibility": "HIDDEN"
                  },
                  {
                    "CustomLabel": "Duur Dienst",
                    "FieldId": "89269437-bef4-471c-8ca6-2fe96e19b1c0.13.1721116655396"
                  },
                  {
                    "CustomLabel": "Afgerond",
                    "FieldId": "c36e82d0-ea12-402f-8861-c1bc34463009.2.1696411698251",
                    "Width": "82px"
                  },
                  {
                    "CustomLabel": "Overig",
                    "FieldId": "42bea99a-30e0-42af-9167-630d160bebcf.10.1702300257103"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftid",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftid.10.1713438007242"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.0.1696411037393"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.employee.6.1697007256431"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualstarted",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualstarted.10.1697014216718",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM D, YYYY H:mm",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        }
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftactualended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftactualended.12.1697014228758",
                        "FormatConfiguration": {
                          "DateTimeFormat": "MMM D, YYYY H:mm",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        }
                      }
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "(diensten) selectie geel",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "21d3a674-1d25-41eb-b508-bf4114d22c08.12.1713439055691"
                      }
                    },
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
                          "ColumnName": "Uitgevoerd Volgens Rooster ",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                          "ColumnName": "Uitvoering Binnen Tijdslimit",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "80984ba5-8c36-4d0c-a665-c3093c3a69f0.12.1697027480037",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                      "CategoricalMeasureField": {
                        "AggregationFunction": "COUNT",
                        "Column": {
                          "ColumnName": "selected_workshift",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "01b6764a-7590-48ed-b83c-58b70bfd8329.11.1713438133531"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "MAX"
                        },
                        "Column": {
                          "ColumnName": "Duration workshift actual",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "89269437-bef4-471c-8ca6-2fe96e19b1c0.13.1721116655396"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "DISTINCT_COUNT"
                        },
                        "Column": {
                          "ColumnName": "afgeronde alarmen",
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
                          "ColumnName": "stefan - Overig",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "42bea99a-30e0-42af-9167-630d160bebcf.10.1702300257103"
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
                  "Border": {
                    "UniformBorder": {
                      "Color": "#B7B7B7",
                      "Style": "SOLID",
                      "Thickness": 1
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 39,
                  "HorizontalTextAlignment": "CENTER",
                  "TextWrap": "WRAP"
                },
                "HeaderStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "NONE",
                      "Thickness": 1
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 33,
                  "HorizontalTextAlignment": "CENTER",
                  "TextWrap": "WRAP",
                  "VerticalTextAlignment": "BOTTOM",
                  "Visibility": "VISIBLE"
                },
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
                }
              },
              "TotalOptions": {
                "CustomLabel": "",
                "Placement": "END",
                "ScrollStatus": "SCROLLED",
                "TotalCellStyle": {
                  "BackgroundColor": "#F4F0F0",
                  "Border": {
                    "UniformBorder": {
                      "Color": "#B7B7B7",
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  }
                },
                "TotalsVisibility": "HIDDEN"
              }
            },
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Row": {
                    "BackgroundColor": {
                      "Solid": {
                        "Color": "#F9B218",
                        "Expression": "MAX({(diensten) selectie geel}) = 10"
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "626f7356-1bf9-4c6f-8c2b-b4747c3acdbc.12.1697026481986",
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "{Uitgevoerd Volgens Rooster } <= 0.6"
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
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "{Uitvoering Binnen Tijdslimit} <= 0.6"
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
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "AVG({Workshift te vroeg gestopt}) > 10"
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
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "AVG({Workshift te laat begonnen}) > 10"
                        }
                      }
                    }
                  }
                }
              ]
            },
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "Visibility": "HIDDEN"
            },
            "VisualId": "b39574ad-e214-4837-8565-ed8aee7223ff"
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
                "CustomActionId": "892d6ffe-6247-4a52-ab35-acffb9354cdc",
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
                        "DataPathType": {
                          "PivotTableDataPathType": "MULTIPLE_ROW_METRICS_COLUMN"
                        }
                      }
                    ],
                    "Width": "192px"
                  }
                ],
                "SelectedFieldOptions": [
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.2.1713338550939",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "FieldId": "c10090a8-0c74-477a-8993-f482308f513a.7.1713346152376",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.9.1713441697632",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.7.1713346832406",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713338581249",
                    "Visibility": "HIDDEN"
                  },
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.6.1713342844992",
                    "Visibility": "HIDDEN"
                  },
                  {
                    "CustomLabel": "Geplande Duur",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.4.1713338849965",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Daadwerkelijke Duur",
                    "FieldId": "71b7e456-7ae0-43a0-a40c-df0aa2db7b54.5.1713338860550",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Reistijd",
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1713348758953",
                    "Visibility": "VISIBLE"
                  },
                  {
                    "CustomLabel": "Volgens Rooster",
                    "FieldId": "435da692-2a12-4275-9e98-690b763acdd4.10.1713443414305",
                    "Visibility": "VISIBLE"
                  }
                ]
              },
              "FieldWells": {
                "PivotTableAggregatedFieldWells": {
                  "Columns": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "Date to string",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "c10090a8-0c74-477a-8993-f482308f513a.7.1713346152376",
                        "FormatConfiguration": {}
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.objectname.9.1713441697632"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "productname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.productname.7.1713346832406"
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.started.2.1713338581249",
                        "FormatConfiguration": {
                          "DateTimeFormat": "H:mm",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        }
                      }
                    },
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "ended",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "DateGranularity": "MINUTE",
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.ended.6.1713342844992",
                        "FormatConfiguration": {
                          "DateTimeFormat": "H:mm",
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        }
                      }
                    }
                  ],
                  "Rows": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "workshiftname",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.2.1713338550939"
                      }
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "duration",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.4.1713338849965",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
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
                              "Suffix": " min"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "duur_werkzaamheden",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "71b7e456-7ae0-43a0-a40c-df0aa2db7b54.5.1713338860550",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Suffix": " min"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "traveltime",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1713348758953",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "SeparatorConfiguration": {
                                "ThousandsSeparator": {
                                  "Visibility": "HIDDEN"
                                }
                              },
                              "Suffix": " min"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "COUNT"
                        },
                        "Column": {
                          "ColumnName": "Parameter Uitgevoerd Binnen Rooster task",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "435da692-2a12-4275-9e98-690b763acdd4.10.1713443414305"
                      }
                    }
                  ]
                }
              },
              "SortConfiguration": {
                "FieldSortOptions": [
                  {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.workshiftname.2.1713338550939",
                    "SortBy": {
                      "Column": {
                        "AggregationFunction": {
                          "DateAggregationFunction": "COUNT"
                        },
                        "Direction": "ASC",
                        "SortBy": {
                          "ColumnName": "started",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        }
                      }
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "UniformBorder": {
                      "Style": "SOLID"
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 35,
                  "HorizontalTextAlignment": "RIGHT"
                },
                "ColumnHeaderStyle": {
                  "FontConfiguration": {},
                  "Height": 37
                },
                "ColumnNamesVisibility": "HIDDEN",
                "DefaultCellWidth": "150px",
                "MetricPlacement": "ROW",
                "RowAlternateColorOptions": {
                  "Status": "ENABLED",
                  "UsePrimaryBackgroundColor": "ENABLED"
                },
                "RowFieldNamesStyle": {
                  "FontConfiguration": {},
                  "Height": 37
                },
                "RowHeaderStyle": {
                  "Border": {
                    "SideSpecificBorder": {
                      "InnerHorizontal": {
                        "Style": "SOLID"
                      }
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  }
                },
                "RowsLabelOptions": {
                  "Visibility": "VISIBLE"
                },
                "RowsLayout": "HIERARCHY",
                "SingleMetricVisibility": "HIDDEN",
                "ToggleButtonsVisibility": "HIDDEN"
              },
              "TotalOptions": {
                "RowSubtotalOptions": {
                  "CustomLabel": "<<$aws:subtotalDimension>> Subtotal",
                  "MetricHeaderCellStyle": {},
                  "StyleTargets": [
                    {
                      "CellType": "VALUE"
                    },
                    {
                      "CellType": "TOTAL"
                    },
                    {
                      "CellType": "METRIC_HEADER"
                    }
                  ],
                  "TotalCellStyle": {},
                  "TotalsVisibility": "VISIBLE",
                  "ValueCellStyle": {}
                }
              }
            },
            "ConditionalFormatting": {
              "ConditionalFormattingOptions": [
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.traveltime.8.1713348758953",
                    "Scopes": [
                      {
                        "Role": "FIELD"
                      }
                    ],
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#DE3B00",
                          "Expression": "DISTINCT_COUNT({reistijd overschreden}) >= 1"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "71b7e456-7ae0-43a0-a40c-df0aa2db7b54.5.1713338860550",
                    "Scopes": [
                      {
                        "Role": "FIELD"
                      }
                    ],
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "COUNT({parameter Taskid _binnen_de_tijdslimiet}) = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "66216a0d-6e60-49a3-b6eb-48d8bfa14d88.duration.4.1713338849965",
                    "Scopes": [
                      {
                        "Role": "FIELD"
                      }
                    ],
                    "TextFormat": {
                      "BackgroundColor": {
                        "Solid": {
                          "Color": "#4A90E2",
                          "Expression": "COUNT({parameter Taskid _binnen_de_tijdslimiet}) = 0"
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "435da692-2a12-4275-9e98-690b763acdd4.10.1713443414305",
                    "Scopes": [
                      {
                        "Role": "FIELD"
                      }
                    ],
                    "TextFormat": {
                      "Icon": {
                        "CustomCondition": {
                          "Color": "#2CAD00",
                          "DisplayConfiguration": {
                            "IconDisplayOption": "ICON_ONLY"
                          },
                          "Expression": "COUNT({Parameter Uitgevoerd Binnen Rooster task}) = 1",
                          "IconOptions": {
                            "Icon": "CHECKMARK"
                          }
                        }
                      }
                    }
                  }
                },
                {
                  "Cell": {
                    "FieldId": "435da692-2a12-4275-9e98-690b763acdd4.10.1713443414305",
                    "Scopes": [
                      {
                        "Role": "FIELD"
                      }
                    ],
                    "TextFormat": {
                      "Icon": {
                        "CustomCondition": {
                          "Color": "#DE3B00",
                          "DisplayConfiguration": {
                            "IconDisplayOption": "ICON_ONLY"
                          },
                          "Expression": "COUNT({Parameter Uitgevoerd Binnen Rooster task}) = 0",
                          "IconOptions": {
                            "Icon": "X"
                          }
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
                "RichText": "<visual-title>Dienst analyse</visual-title>"
              },
              "Visibility": "HIDDEN"
            },
            "VisualId": "ecee5303-d8ad-4277-b6f0-2bd786247d65"
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
                "Visibility": "VISIBLE"
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
            "FilterControlId": "2ee3a60a-07c7-4a46-a484-51b81c9347a4",
            "SourceFilterId": "bc2723db-54fc-4983-ba0f-eeecd3bae5d7",
            "Title": "Jaar",
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
                "FontConfiguration": {},
                "Visibility": "VISIBLE"
              }
            },
            "FilterControlId": "95f72bc0-034c-4589-a27b-dd03a40b8b6b",
            "SourceFilterId": "e484db02-1937-4477-b8ce-f5975fa0ec83",
            "Title": "Maand",
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
            "FilterControlId": "da662e0b-7958-4c42-98b5-81d2320cac40",
            "SourceFilterId": "e1cd4136-e232-4664-8342-5fdca7766fc8",
            "Title": "Dag van de Week",
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
                  "OptimizedViewPortWidth": "1600px",
                  "ResizeOption": "FIXED"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "38277f9d-9d40-467d-9a74-e26607dfba1d",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 4
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 8,
                  "ElementId": "2ee3a60a-07c7-4a46-a484-51b81c9347a4",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 22,
                  "ElementId": "9835e990-989f-43b1-a59f-4f4d3d07332c",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 4,
                  "ElementId": "95f72bc0-034c-4589-a27b-dd03a40b8b6b",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 2,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 4,
                  "ElementId": "da662e0b-7958-4c42-98b5-81d2320cac40",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 2,
                  "RowSpan": 2
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 14,
                  "ElementId": "3c751cc9-219c-4459-8ef9-ac7b2eaf5bf7",
                  "ElementType": "VISUAL",
                  "RowIndex": 4,
                  "RowSpan": 20
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 22,
                  "ElementId": "e6855a84-b673-4f40-8db3-c48eda6574d8",
                  "ElementType": "VISUAL",
                  "RowIndex": 8,
                  "RowSpan": 8
                },
                {
                  "ColumnIndex": 14,
                  "ColumnSpan": 22,
                  "ElementId": "6d11dd67-b214-4735-b135-3dbbc47224f2",
                  "ElementType": "VISUAL",
                  "RowIndex": 16,
                  "RowSpan": 8
                }
              ]
            }
          }
        }
      ],
      "Name": "Opbrengsten Surveillance",
      "ParameterControls": [
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "c6e6bec9-1bca-4981-a619-a8fc828806f3",
            "SourceParameterName": "from",
            "Title": "Van"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "c1ee28ef-9f92-4e2d-8c9e-0e41786d75a2",
            "SourceParameterName": "to",
            "Title": "Tot"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "38277f9d-9d40-467d-9a74-e26607dfba1d",
            "SelectableValues": {
              "Values": [
                "Diensten",
                "Dienstenverlening",
                "Klanten",
                "Regio"
              ]
            },
            "SourceParameterName": "ControlOpbrengsten",
            "Title": "a",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
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
            "ParameterControlId": "b6eacab7-b49b-48b5-8b3f-b0fffff4632c",
            "SelectableValues": {
              "Values": [
                "1. Dag",
                "2. Week",
                "3. Maand",
                "4. Kwartaal",
                "5. Jaar"
              ]
            },
            "SourceParameterName": "dateSelectionAggregation",
            "Title": "Interval",
            "Type": "SINGLE_SELECT"
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
            "ParameterControlId": "51bd24d7-6545-4b33-9d9d-d5820d8384ef",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "objectname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "object",
            "Title": "Risicoadressen",
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
            "ParameterControlId": "288b36cd-5046-4993-b84a-23e8c2755adc",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "customername",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "klanten",
            "Title": "Klanten",
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
            "ParameterControlId": "ce4dd0ad-6e4c-4e32-bac4-7c4caa5984ee",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "regionname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Regio",
            "Title": "Regio",
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
            "ParameterControlId": "8e841d05-8046-4a16-b07b-93441305846c",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "alarmtype prio",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "alarmprio",
            "Title": "Prio",
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
            "ParameterControlId": "473e6b45-9ea8-4a8f-8d88-64a58b7487d8",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "endreason",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Endreason",
            "Title": "Eindreden",
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
            "ParameterControlId": "fee5b193-0e5c-4a85-b872-66ceba77f53e",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "workshifttype",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "Workshifttype",
            "Title": "Diensttype",
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
            "ParameterControlId": "52f296be-80c3-47f9-88b3-04781783e260",
            "SelectableValues": {
              "LinkToDataSetColumn": {
                "ColumnName": "productname",
                "DataSetIdentifier": "sequrix_tasks_records"
              }
            },
            "SourceParameterName": "productname",
            "Title": "Dienstverlening",
            "Type": "MULTI_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "b6eacab7-b49b-48b5-8b3f-b0fffff4632c",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "c6e6bec9-1bca-4981-a619-a8fc828806f3",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "c1ee28ef-9f92-4e2d-8c9e-0e41786d75a2",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "51bd24d7-6545-4b33-9d9d-d5820d8384ef",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "288b36cd-5046-4993-b84a-23e8c2755adc",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 2,
                  "ElementId": "ce4dd0ad-6e4c-4e32-bac4-7c4caa5984ee",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "52f296be-80c3-47f9-88b3-04781783e260",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "8e841d05-8046-4a16-b07b-93441305846c",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "473e6b45-9ea8-4a8f-8d88-64a58b7487d8",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "fee5b193-0e5c-4a85-b872-66ceba77f53e",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 1,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8",
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
                "CustomActionId": "0df42467-9e51-409b-9a0b-11107c0ed46f",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "DataOptions": {
                  "DateAxisOptions": {
                    "MissingDateVisibility": "HIDDEN"
                  }
                },
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "SMALL"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "FormatConfiguration": {
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        },
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                      }
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
                          "ColumnName": "stefan - totaal hours alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "083942eb-eed2-44fc-990c-3e0b6dc34c98.2.1723463232939",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "Totaal hours last Year",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "b0912226-16e7-4e5e-867d-59a08df570c1.2.1723463222971",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
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
              "Legend": {
                "Height": "73px",
                "Position": "TOP",
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "120px"
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
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
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
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "083942eb-eed2-44fc-990c-3e0b6dc34c98.2.1723463232939",
                        "Label": "Dit Jaar",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "b0912226-16e7-4e5e-867d-59a08df570c1.2.1723463222971",
                        "Label": "Vorig Jaar",
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
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>Totaal Aantal Uren</b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "6d11dd67-b214-4735-b135-3dbbc47224f2"
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
                "CustomActionId": "e4385c61-3017-47d6-a19d-4a0007d2a09f",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "DataOptions": {
                  "DateAxisOptions": {
                    "MissingDateVisibility": "HIDDEN"
                  }
                },
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "SMALL"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "FormatConfiguration": {
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        },
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                      }
                    }
                  ],
                  "Colors": [],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "Omzet per uur",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "85f458fc-92ec-4116-bf3a-65f29c4cd2af.2.1723456346337",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "CurrencyDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "POSITIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Symbol": "EUR"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "Omzet per uur last Year",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "3ef6047c-b8ac-4f9a-adad-fd989ce0a9f1.2.1723456507058",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "CurrencyDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 2
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "POSITIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Symbol": "USD"
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Height": "73px",
                "Position": "TOP",
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "120px"
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
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
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
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "85f458fc-92ec-4116-bf3a-65f29c4cd2af.2.1723456346337",
                        "Label": "Dit Jaar",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "3ef6047c-b8ac-4f9a-adad-fd989ce0a9f1.2.1723456507058",
                        "Label": "Vorig Jaar",
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
                "AxisOffset": "71px",
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>Opbrengsten P</b>\n  </inline>\n  <inline font-size=\"16px\"/>\n  <inline font-size=\"16px\">\n    <b>er Uur</b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "e6855a84-b673-4f40-8db3-c48eda6574d8"
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
                "CustomActionId": "da4bc094-9688-46bc-93af-bacf48bc3885",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "BarsArrangement": "CLUSTERED",
              "CategoryAxis": {
                "AxisLineVisibility": "VISIBLE",
                "DataOptions": {
                  "DateAxisOptions": {
                    "MissingDateVisibility": "HIDDEN"
                  }
                },
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                },
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "DataLabels": {
                "LabelFontConfiguration": {
                  "FontSize": {
                    "Relative": "SMALL"
                  }
                },
                "Overlap": "DISABLE_OVERLAP",
                "Position": "TOP",
                "Visibility": "VISIBLE"
              },
              "FieldWells": {
                "BarChartAggregatedFieldWells": {
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "Datum1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "FormatConfiguration": {
                          "NullValueFormatConfiguration": {
                            "NullString": "null"
                          }
                        },
                        "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                      }
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
                          "ColumnName": "(opbrengsten) Grafiek 1",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e71bacb0-03cd-434e-9fef-3f7caf9a582b.1.1713254596945",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "CurrencyDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "POSITIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Symbol": "EUR"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "Omzet last Year",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "20afc05a-6fb0-4af5-9eeb-17adfc10d7cc.2.1723450010903",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "CurrencyDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "POSITIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Symbol": "EUR"
                            }
                          }
                        }
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Height": "73px",
                "Position": "TOP",
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN",
                "Width": "120px"
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
                      "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
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
                        "FieldId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "e71bacb0-03cd-434e-9fef-3f7caf9a582b.1.1713254596945",
                        "Label": "Dit Jaar",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "20afc05a-6fb0-4af5-9eeb-17adfc10d7cc.2.1723450010903",
                        "Label": "Vorig Jaar",
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
                "AxisOffset": "80px",
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "FontConfiguration": {
                      "FontSize": {
                        "Relative": "MEDIUM"
                      }
                    },
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
                  "HierarchyId": "a88506bb-7457-44bd-bd88-c40ed7f8bd8d.1.1711370016595"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "HIDDEN"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <inline font-size=\"16px\">\n    <b>\n      <parameter>$${Opbrengsten}</parameter>\n    </b>\n  </inline>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "9835e990-989f-43b1-a59f-4f4d3d07332c"
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
                "CustomActionId": "fa446b30-5800-44b0-883c-0e9537ec4996",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "<<$ControlOpbrengsten>>",
                    "FieldId": "fa3c1735-110f-46a0-b605-8ba73ff46bd5.3.1713253756744",
                    "Width": "266px"
                  },
                  {
                    "CustomLabel": "Per Uur",
                    "FieldId": "86f29d89-8811-4fbb-946b-4ec949b32a6b.4.1707060171745",
                    "Width": "90px"
                  },
                  {
                    "CustomLabel": "Totale Uren",
                    "FieldId": "083942eb-eed2-44fc-990c-3e0b6dc34c98.5.1707060209512",
                    "Width": "105px"
                  },
                  {
                    "CustomLabel": "Totaal",
                    "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501",
                    "Width": "101px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "(Opbrengsten) table",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "fa3c1735-110f-46a0-b605-8ba73ff46bd5.3.1713253756744"
                      }
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "stefan -  object turnover per hour",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "86f29d89-8811-4fbb-946b-4ec949b32a6b.4.1707060171745",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "CurrencyDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "POSITIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Symbol": "EUR"
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "stefan - totaal hours alarmtype",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "083942eb-eed2-44fc-990c-3e0b6dc34c98.5.1707060209512",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "NumberDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "DOT",
                                "ThousandsSeparator": {
                                  "Symbol": "COMMA",
                                  "Visibility": "HIDDEN"
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "AggregationFunction": {
                          "SimpleNumericalAggregation": "SUM"
                        },
                        "Column": {
                          "ColumnName": "turnover",
                          "DataSetIdentifier": "sequrix_tasks_records"
                        },
                        "FieldId": "e57c4880-af5e-4eea-89fa-2b886d37b33d.turnover.1.1644590677501",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "CurrencyDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "POSITIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
                              },
                              "NumberScale": "NONE",
                              "SeparatorConfiguration": {
                                "DecimalSeparator": "COMMA",
                                "ThousandsSeparator": {
                                  "Symbol": "DOT",
                                  "Visibility": "VISIBLE"
                                }
                              },
                              "Symbol": "EUR"
                            }
                          }
                        }
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
                      "FieldId": "083942eb-eed2-44fc-990c-3e0b6dc34c98.5.1707060209512"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 30,
                  "HorizontalTextAlignment": "AUTO",
                  "TextWrap": "WRAP"
                },
                "HeaderStyle": {
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 30,
                  "TextWrap": "WRAP"
                },
                "Orientation": "VERTICAL"
              },
              "TotalOptions": {
                "Placement": "END",
                "ScrollStatus": "SCROLLED",
                "TotalsVisibility": "VISIBLE"
              }
            },
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>Opbrengst per object</visual-title>"
              },
              "Visibility": "HIDDEN"
            },
            "VisualId": "3c751cc9-219c-4459-8ef9-ac7b2eaf5bf7"
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
            "FilterControlId": "7a8f777e-d732-4f6f-931d-ec0960f4c158",
            "SourceFilterId": "37e73c91-9504-44e8-b1aa-ab4613940356",
            "Title": "Risico-adres",
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
            "FilterControlId": "36c33007-4a8b-4171-9a34-bc3362e39e95",
            "SourceFilterId": "f90baf94-a3d4-4d43-a1f8-40f0883d5ea8",
            "Title": "Medewerkers",
            "Type": "MULTI_SELECT"
          }
        },
        {
          "Slider": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "FilterControlId": "f91f0993-63d8-4c1f-832b-f1979756764f",
            "MaximumValue": 100,
            "MinimumValue": 0,
            "SourceFilterId": "c09b75b0-efdc-4532-a023-ef4988b2b0eb",
            "StepSize": 5,
            "Title": "Afstand tot locatie",
            "Type": "SINGLE_POINT"
          }
        }
      ],
      "Layouts": [
        {
          "Configuration": {
            "GridLayout": {
              "CanvasSizeOptions": {
                "ScreenCanvasSizeOptions": {
                  "OptimizedViewPortWidth": "1600px",
                  "ResizeOption": "FIXED"
                }
              },
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 6,
                  "ElementId": "b7c9c7e6-e618-40db-8029-bc02ba0edce7",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 6,
                  "ElementId": "ad0a0b41-f92c-4cc5-8109-f1166293f7bc",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 3
                },
                {
                  "ColumnIndex": 12,
                  "ColumnSpan": 24,
                  "ElementId": "e46cfcad-bb7d-4083-a5ee-f9eb22c7c040",
                  "ElementType": "VISUAL",
                  "RowIndex": 0,
                  "RowSpan": 12
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 12,
                  "ElementId": "45c0fbc5-cfe1-4ddc-ade0-547cc61e47e7",
                  "ElementType": "VISUAL",
                  "RowIndex": 3,
                  "RowSpan": 9
                },
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 36,
                  "ElementId": "172a9742-0913-4b5f-bf86-7854036525a8",
                  "ElementType": "VISUAL",
                  "RowIndex": 12,
                  "RowSpan": 12
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
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "b13bdbf5-2e4c-41f1-8fe9-2802168dfca7",
            "SourceParameterName": "from",
            "Title": "Van"
          }
        },
        {
          "DateTimePicker": {
            "DisplayOptions": {
              "DateTimeFormat": "YYYY/MM/DD",
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "b3350576-ba4b-41e1-90a4-a3935b34195b",
            "SourceParameterName": "to",
            "Title": "Tot"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
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
            "ParameterControlId": "984ba86d-1811-427f-a28b-27d77a0343c9",
            "SelectableValues": {
              "Values": [
                "1. Dag",
                "2. Week",
                "3. Maand",
                "4. Kwartaal",
                "5. Jaar"
              ]
            },
            "SourceParameterName": "dateSelectionAggregation",
            "Title": "Interval",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "b7c9c7e6-e618-40db-8029-bc02ba0edce7",
            "SelectableValues": {
              "Values": [
                "Locatie",
                "Medewerker",
                "Object",
                "Regio"
              ]
            },
            "SourceParameterName": "scansselect",
            "Title": "select",
            "Type": "SINGLE_SELECT"
          }
        },
        {
          "List": {
            "DisplayOptions": {
              "InfoIconLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SearchOptions": {
                "Visibility": "HIDDEN"
              },
              "SelectAllOptions": {
                "Visibility": "HIDDEN"
              },
              "TitleOptions": {
                "FontConfiguration": {
                  "FontSize": {
                    "Relative": "MEDIUM"
                  }
                },
                "Visibility": "HIDDEN"
              }
            },
            "ParameterControlId": "ad0a0b41-f92c-4cc5-8109-f1166293f7bc",
            "SelectableValues": {
              "Values": [
                "Aantal handmatig gescand",
                "Aantal scans"
              ]
            },
            "SourceParameterName": "Scandata",
            "Title": "data",
            "Type": "SINGLE_SELECT"
          }
        }
      ],
      "SheetControlLayouts": [
        {
          "Configuration": {
            "GridLayout": {
              "Elements": [
                {
                  "ColumnIndex": 0,
                  "ColumnSpan": 2,
                  "ElementId": "984ba86d-1811-427f-a28b-27d77a0343c9",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 2,
                  "ColumnSpan": 2,
                  "ElementId": "f91f0993-63d8-4c1f-832b-f1979756764f",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 4,
                  "ColumnSpan": 2,
                  "ElementId": "b13bdbf5-2e4c-41f1-8fe9-2802168dfca7",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 6,
                  "ColumnSpan": 2,
                  "ElementId": "b3350576-ba4b-41e1-90a4-a3935b34195b",
                  "ElementType": "PARAMETER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 8,
                  "ColumnSpan": 2,
                  "ElementId": "7a8f777e-d732-4f6f-931d-ec0960f4c158",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                },
                {
                  "ColumnIndex": 10,
                  "ColumnSpan": 2,
                  "ElementId": "36c33007-4a8b-4171-9a34-bc3362e39e95",
                  "ElementType": "FILTER_CONTROL",
                  "RowIndex": 0,
                  "RowSpan": 1
                }
              ]
            }
          }
        }
      ],
      "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e",
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
                "CustomActionId": "7a193ec5-3c7f-4422-8c33-8fd68006ecb1",
                "Name": "Action 1",
                "Status": "ENABLED",
                "Trigger": "DATA_POINT_CLICK"
              }
            ],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "<<$Scandata>>",
                    "FieldId": "7757e093-68d6-4c06-80af-d3ae22b14d76.2.1744021641436",
                    "Width": "255px"
                  },
                  {
                    "CustomLabel": "Aantal",
                    "FieldId": "de1d466a-6d4c-4840-896c-457270319b62.2.1744030173099",
                    "Width": "75px"
                  },
                  {
                    "CustomLabel": "%",
                    "FieldId": "8bea71fa-e54c-4759-a398-fd27cf1527f3.2.1707846250780",
                    "Width": "78px"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "scanselectie",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "7757e093-68d6-4c06-80af-d3ae22b14d76.2.1744021641436"
                      }
                    }
                  ],
                  "Values": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "scandataselectie",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "de1d466a-6d4c-4840-896c-457270319b62.2.1744030173099"
                      }
                    },
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "Percentage handmatig gescand",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "8bea71fa-e54c-4759-a398-fd27cf1527f3.2.1707846250780",
                        "FormatConfiguration": {
                          "FormatConfiguration": {
                            "PercentageDisplayFormatConfiguration": {
                              "DecimalPlacesConfiguration": {
                                "DecimalPlaces": 0
                              },
                              "NegativeValueConfiguration": {
                                "DisplayMode": "NEGATIVE"
                              },
                              "NullValueFormatConfiguration": {
                                "NullString": "null"
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
                      "Direction": "DESC",
                      "FieldId": "de1d466a-6d4c-4840-896c-457270319b62.2.1744030173099"
                    }
                  }
                ]
              },
              "TableOptions": {
                "CellStyle": {
                  "Border": {
                    "SideSpecificBorder": {
                      "InnerHorizontal": {
                        "Style": "SOLID",
                        "Thickness": 1
                      }
                    }
                  },
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
                  },
                  "Height": 35
                },
                "HeaderStyle": {
                  "FontConfiguration": {
                    "FontSize": {
                      "Relative": "LARGE"
                    }
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
              "Visibility": "HIDDEN"
            },
            "VisualId": "45c0fbc5-cfe1-4ddc-ade0-547cc61e47e7"
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
              "BarsArrangement": "STACKED",
              "CategoryAxis": {
                "ScrollbarOptions": {
                  "Visibility": "HIDDEN"
                }
              },
              "CategoryLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "FieldWells": {
                "ComboChartAggregatedFieldWells": {
                  "BarValues": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "scandataselectie",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "de1d466a-6d4c-4840-896c-457270319b62.2.1744022279965"
                      }
                    }
                  ],
                  "Category": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "datum1",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "eb3c8eec-c9ee-407b-8ef2-bf143ef6a2d2.0.1744020932813",
                        "HierarchyId": "eb3c8eec-c9ee-407b-8ef2-bf143ef6a2d2.0.1744020932813"
                      }
                    }
                  ],
                  "Colors": [],
                  "LineValues": [
                    {
                      "NumericalMeasureField": {
                        "Column": {
                          "ColumnName": "Percentage handmatig gescand",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "8bea71fa-e54c-4759-a398-fd27cf1527f3.2.1744030638934"
                      }
                    }
                  ]
                }
              },
              "Legend": {
                "Position": "TOP",
                "Title": {
                  "Visibility": "HIDDEN"
                },
                "Visibility": "HIDDEN"
              },
              "LineDataLabels": {
                "Overlap": "DISABLE_OVERLAP"
              },
              "PrimaryYAxisDisplayOptions": {
                "GridLineVisibility": "VISIBLE",
                "TickLabelOptions": {
                  "LabelOptions": {
                    "Visibility": "VISIBLE"
                  }
                }
              },
              "PrimaryYAxisLabelOptions": {
                "SortIconVisibility": "HIDDEN",
                "Visibility": "HIDDEN"
              },
              "SecondaryYAxisLabelOptions": {
                "Visibility": "HIDDEN"
              },
              "SortConfiguration": {
                "CategoryItemsLimit": {
                  "OtherCategories": "INCLUDE"
                },
                "CategorySort": [
                  {
                    "FieldSort": {
                      "Direction": "ASC",
                      "FieldId": "eb3c8eec-c9ee-407b-8ef2-bf143ef6a2d2.0.1744020932813"
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
                        "FieldId": "eb3c8eec-c9ee-407b-8ef2-bf143ef6a2d2.0.1744020932813",
                        "TooltipTarget": "BOTH",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "de1d466a-6d4c-4840-896c-457270319b62.2.1744022279965",
                        "Label": "Aantal",
                        "TooltipTarget": "BAR",
                        "Visibility": "VISIBLE"
                      }
                    },
                    {
                      "FieldTooltipItem": {
                        "FieldId": "8bea71fa-e54c-4759-a398-fd27cf1527f3.2.1744030638934",
                        "Label": "Percentage handmatig gescand",
                        "TooltipTarget": "LINE",
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
                  "HierarchyId": "eb3c8eec-c9ee-407b-8ef2-bf143ef6a2d2.0.1744020932813"
                }
              }
            ],
            "Subtitle": {
              "Visibility": "VISIBLE"
            },
            "Title": {
              "FormatText": {
                "RichText": "<visual-title>\n  <b>\n    <parameter>$${Scandata}</parameter>\n  </b>\n</visual-title>"
              },
              "Visibility": "VISIBLE"
            },
            "VisualId": "e46cfcad-bb7d-4083-a5ee-f9eb22c7c040"
          }
        },
        {
          "TableVisual": {
            "Actions": [],
            "ChartConfiguration": {
              "FieldOptions": {
                "SelectedFieldOptions": [
                  {
                    "CustomLabel": "Dag",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.scanneddatetime.0.1744023812685"
                  },
                  {
                    "CustomLabel": "Taak",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.taskid.1.1744023821501"
                  },
                  {
                    "CustomLabel": "PlanningId",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.planningresultcheckpointid.2.1744023832063"
                  },
                  {
                    "CustomLabel": "Object",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.objectname.3.1744023854759"
                  },
                  {
                    "CustomLabel": "Locatie",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.location.4.1744023859765",
                    "Width": "310px"
                  },
                  {
                    "CustomLabel": "Medewerker",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.employee.5.1744023924321"
                  },
                  {
                    "CustomLabel": "Type",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.checkpointtypeenumname.6.1744023930646",
                    "Width": "121px"
                  },
                  {
                    "CustomLabel": "Afstand",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.distancetocheckpointlocation.7.1744023939994"
                  },
                  {
                    "CustomLabel": "Commentaar",
                    "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.comment.8.1744023947370"
                  }
                ]
              },
              "FieldWells": {
                "TableAggregatedFieldWells": {
                  "GroupBy": [
                    {
                      "DateDimensionField": {
                        "Column": {
                          "ColumnName": "scanneddatetime",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.scanneddatetime.0.1744023812685"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "taskid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.taskid.1.1744023821501"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "planningresultcheckpointid",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.planningresultcheckpointid.2.1744023832063"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "objectname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.objectname.3.1744023854759"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "location",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.location.4.1744023859765"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "employee",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.employee.5.1744023924321"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "checkpointtypeenumname",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.checkpointtypeenumname.6.1744023930646"
                      }
                    },
                    {
                      "NumericalDimensionField": {
                        "Column": {
                          "ColumnName": "distancetocheckpointlocation",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.distancetocheckpointlocation.7.1744023939994"
                      }
                    },
                    {
                      "CategoricalDimensionField": {
                        "Column": {
                          "ColumnName": "comment",
                          "DataSetIdentifier": "sequrix_planning_records"
                        },
                        "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.comment.8.1744023947370"
                      }
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
                      "FieldId": "ff7374b0-8635-47bd-a87b-3d751f53420b.distancetocheckpointlocation.7.1744023939994"
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
              "Visibility": "HIDDEN"
            },
            "Title": {
              "Visibility": "HIDDEN"
            },
            "VisualId": "172a9742-0913-4b5f-bf86-7854036525a8"
          }
        }
      ]
    }
  ]
}
EOT
}

resource "specifai_quicksight_dashboard" "test" {
  dashboard_id        = "terraform-provider-test-dashboards2"
  name                = "Terraform Provider Test Dashboard"
  version_description = "..."
  definition          = data.specifai_normalized_dashboard_definition.test.normalized_definition
}

#resource "specifai_quicksight_dashboard_permission" "test" {
#  dashboard_id = "terraform-provider-test-dashboard"
#  principal    = "arn:aws:quicksight:eu-west-1:296896140035:user/default/quicksight_sso/marcel@meulemans.engineering"
#  actions = [
#    "quicksight:DescribeDashboard",
#    "quicksight:ListDashboardVersions",
#    "quicksight:QueryDashboard"
#  ]
#}

# output "dashboard" {
#  value = specifai_quicksight_dashboard.test
# }

# output "definition" {
#   value = data.specifai_normalized_dashboard_definition.test
# }

#output "permission" {
#  value = specifai_quicksight_dashboard_permission.test.actions
#}
