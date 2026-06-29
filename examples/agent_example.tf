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

# Create a space for the agent's data
resource "specifai_quicksight_space" "sales_space" {
  space_id    = "sales-space"
  name        = "Sales Space"
  description = "Space containing sales analytics data"
}

resource "specifai_quicksight_space_permission" "sales_space_owner" {
  space_id  = specifai_quicksight_space.sales_space.space_id
  principal = "arn:aws:quicksight:us-east-1:123456789012:user/default/admin"
  actions = [
    "quicksight:DescribeSpace",
    "quicksight:UpdateSpace",
    "quicksight:DeleteSpace",
    "quicksight:DescribeSpacePermissions",
    "quicksight:UpdateSpacePermissions"
  ]
}

# Create an agent connected to the space
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

  # Connect the space to the agent
  spaces = [specifai_quicksight_space.sales_space.arn]
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

# Read the agent back via data source
data "specifai_quicksight_agent" "sales_agent" {
  agent_id = specifai_quicksight_agent.sales_agent.agent_id
}

output "agent_arn" {
  value = data.specifai_quicksight_agent.sales_agent.arn
}

output "agent_status" {
  value = data.specifai_quicksight_agent.sales_agent.agent_status
}
