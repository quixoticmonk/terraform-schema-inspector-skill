# Terraform Schema Inspector Skill

Agent skill for identifying Terraform provider support for resources, data sources, actions, list resources, ephemeral resources, and functions.

**Links:** [skills.sh](https://skills.sh/quixoticmonk/terraform-schema-inspector-skill/terraform-schema-inspector-skill) | [GitHub](https://github.com/quixoticmonk/terraform-schema-inspector-skill) | [Security Audit](https://skills.sh/quixoticmonk/terraform-schema-inspector-skill/terraform-schema-inspector-skill/security/agent-trust-hub)

## Installation

**Via skills library:**

```bash
npx skills add quixoticmonk/terraform-schema-inspector-skill
```

**Manual installation:**

Copy this directory to your agent's skills folder.

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

## Supported Capability Types

- `resources` - Standard managed resources
- `data-sources` - Read-only data sources
- `actions` - Imperative lifecycle actions (Terraform 1.14+)
- `ephemeral` - Ephemeral resources for credentials/tokens (Terraform 1.10+)
- `functions` - Provider-specific functions
- `list` - List resource capabilities

## How It Works

The skill uses `terraform providers schema -json` to extract provider capabilities. The agent:
1. Uses the Terraform MCP server to determine the correct provider namespace and version
2. Creates a minimal provider configuration in a temporary directory
3. Runs the `check.sh` script which initializes Terraform and extracts the schema
4. Queries the schema for the requested capability type
5. Cleans up temporary files

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
