terraform {
  required_providers {
    specifai = {
      source = "specifai-net/specifai"
    }
  }
}

provider "specifai" {
  region = "us-east-1"
}

resource "specifai_quicksight_agent" "sales_agent" {
  agent_id        = "sales-agent"
  name            = "Sales Analytics Agent"
  description     = "An agent that helps with sales data analysis"
  agent_lifecycle = "PUBLISHED"
  welcome_message = "Hello! I can help you analyze sales data."

  custom_instructions = "Focus on sales metrics, revenue trends, and customer segmentation."
  identity            = "You are a sales analytics assistant."
  tone                = "Professional and concise"
  output_style        = "Use tables and charts when possible"
  response_length     = "Medium"

  starter_prompts = [
    "What were last month's total sales?",
    "Show me the top 10 customers by revenue",
    "Compare this quarter to last quarter"
  ]
}

resource "specifai_quicksight_agent_permission" "sales_agent_owner" {
  agent_id  = specifai_quicksight_agent.sales_agent.agent_id
  principal = "arn:aws:quicksight:us-east-1:123456789012:user/default/admin"
  actions = [
    "quicksight:DescribeAgent",
    "quicksight:UpdateAgent",
    "quicksight:DeleteAgent",
    "quicksight:DescribeAgentPermissions",
    "quicksight:UpdateAgentPermissions"
  ]
}

data "specifai_quicksight_agent" "existing" {
  agent_id = "existing-agent-id"
}

output "existing_agent_name" {
  value = data.specifai_quicksight_agent.existing.name
}
