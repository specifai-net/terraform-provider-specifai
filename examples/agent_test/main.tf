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

resource "specifai_quicksight_agent" "test_agent" {
  agent_id        = "test-agent2"
  name            = "Test Agent2"
  description     = "A test agent deployed via Terraform"
  agent_lifecycle = "PUBLISHED"
  welcome_message = "Hello! I'm a test agent. Ask me anything about your data."

  custom_instructions = "You are a helpful analytics assistant. Focus on providing clear data insights."
  identity            = "You are a friendly data analyst named DataBot."
  tone                = "Professional but approachable"
  output_style        = "Use bullet points and tables where possible"
  response_length     = "Medium"

  starter_prompts = [
    "What can you help me with?",
    "Show me a summary of last month's data",
    "What are the key trends?"
  ]
}

resource "specifai_quicksight_agent_permission" "test_agent_owner" {
  agent_id  = specifai_quicksight_agent.test_agent.agent_id
  principal = "arn:aws:quicksight:eu-west-1:296896140035:user/default/quicksight_sso/j.meulendijks@specifai.eu"
  actions = [
    "quicksight:DescribeAgent",
    "quicksight:UpdateAgent",
    "quicksight:DeleteAgent",
    "quicksight:DescribeAgentPermissions",
    "quicksight:UpdateAgentPermissions"
  ]
}
