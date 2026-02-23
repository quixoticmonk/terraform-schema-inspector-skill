# Terraform Schema Inspector Skill

Agent skill for identifying Terraform provider support for resources, data sources, actions, list resources, ephemeral resources, and functions.

## Installation

Copy this directory to your agent's skills folder or install via your agent's skill management system.

## Usage

The agent will automatically use this skill when you ask about Terraform provider capabilities:

- "What ephemeral resources does the AWS provider support?"
- "Show me data sources for azurerm"
- "Does the google provider have any actions?"
- "List all functions in the AWS provider"

The agent will:
1. Create a temporary provider configuration if needed
2. Run the inspection script
3. Present the results
4. Clean up temporary files

## Requirements

- Terraform CLI
- jq (JSON processor)

## How It Works

The skill uses `terraform providers schema -json` to extract provider capabilities. The agent creates a minimal provider configuration, initializes Terraform to download the provider schema, then queries it for the requested capability type.

## Structure

```
terraform-schema-inspector-skill/
├── SKILL.md           # Skill definition and workflow
├── scripts/
│   └── check.sh       # Capability extraction script
├── CHANGELOG.md       # Version history
├── LICENSE            # MIT License
└── README.md          # This file
```

## Example Output

```json
{
  "aws": [
    "aws_cognito_identity_openid_token_for_developer_identity",
    "aws_ecr_authorization_token",
    "aws_eks_cluster_auth",
    "aws_kms_secrets",
    "aws_lambda_invocation",
    "aws_secretsmanager_random_password",
    "aws_secretsmanager_secret_version",
    "aws_ssm_parameter"
  ]
}
```
