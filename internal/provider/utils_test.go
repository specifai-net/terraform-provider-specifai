package provider

import (
	"reflect"
	"testing"
)

func TestJsonToNormalizedDefinitionJson(t *testing.T) {
	inputString := `
{
  "Sheets": [
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [],
      "Name": "KPI",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "5e34bd0d-ce5e-4f35-8514-f347c60c8262",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [],
      "Name": "Risico-address",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "ed10dba4-fc18-4d50-a094-687a1bfcbb14",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [],
      "Name": "Medewerkers",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "7b354836-d5fa-4e98-bd6d-cc660e4b85cf",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [],
      "Name": "Prestatiedashboard",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "0f0edfa3-2438-4684-8b82-f4a91f4661a4",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [],
      "Name": " Diensten",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "36caa6ca-4e2f-4c02-b245-eaf5de88305c",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "FilterControls": [],
      "Layouts": [],
      "Name": "Opbrengsten alarmopvolgingen",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "0bd34c47-576b-4a1f-a7b8-ac7c315817b8",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "FilterControls": [],
      "Layouts": [],
      "Name": "Barcodes",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "af0427ef-384c-4956-bcbb-b2388002ec9e",
      "Visuals": []
    },
    {
      "ContentType": "INTERACTIVE",
      "Layouts": [],
      "Name": "(Demo) Bezetting",
      "ParameterControls": [],
      "SheetControlLayouts": [],
      "SheetId": "2df82fe4-586f-488f-af7a-254733d8fd70",
      "Visuals": []
    }
  ]
}
`
	bytes := []byte(inputString)
	definition, err := JsonToNormalizedDefinition(bytes)
	if err != nil {
		t.Errorf(`Parsing return error %#q`, err)
	}
	var sheetNames []string
	for _, sheet := range definition.Sheets {
		sheetNames = append(sheetNames, *sheet.Name)
	}
	expectedNames := []string{"KPI", "Risico-address", "Medewerkers", "Prestatiedashboard", " Diensten", "Opbrengsten alarmopvolgingen", "Barcodes", "(Demo) Bezetting"}
	if !reflect.DeepEqual(sheetNames, expectedNames) {
		t.Errorf(`Mismatch sheets order, expected %v get %v`, expectedNames, sheetNames)
	}
}
