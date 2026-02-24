---
name: terraform-schema-inspector-skill
description: Identify Terraform provider support for resources, data sources, actions, list resources, ephemeral resources, and functions. Use when checking provider capabilities, asking "what resources does X provider support", "does provider Y have actions", or querying specific provider features.
license: MIT
compatibility: Requires Terraform CLI and jq
metadata:
  author: quixoticmonk
  version: "0.2.0"
---

# Terraform Schema Inspector

Identify which capabilities a Terraform provider supports:
- **Resources**: Standard managed resources
- **Data Sources**: Read-only data queries
- **Actions**: Imperative operations during lifecycle events
- **List Resources**: Resources supporting bulk list operations
- **Ephemeral Resources**: Temporary resources for credentials/tokens
- **Functions**: Provider-specific functions

## Workflow

**CRITICAL: Always use the `scripts/check.sh` script - never manually run terraform commands.**

When a user asks about provider capabilities:

1. **Prepare working directory**
   - Create a temporary directory (e.g., `/tmp/tf-inspect-$$`)
   - Change to that directory

2. **Determine provider source**
   - Use `get_latest_provider_version` tool to find the correct namespace and version
   - Common namespaces: `hashicorp` (aws, google, azurerm), `integrations` (github), `oracle` (oci), etc.

3. **Create provider configuration**
   - Create a minimal `main.tf` file with the provider source from step 2:
     ```hcl
     terraform {
       required_providers {
         <provider> = {
           source = "<namespace>/<provider>"
           version = "~> <version>"
         }
       }
     }
     
     provider "<provider>" {}
     ```
   - Example for AWS: `source = "hashicorp/aws"`
   - Example for GitHub: `source = "integrations/github"`

4. **Run the inspection script**
   ```bash
   /path/to/skill/scripts/check.sh <capability_type> <provider_name>
   ```
   
   The script will:
   - Validate inputs and check dependencies
   - Run `terraform init` automatically
   - Extract the schema using `terraform providers schema -json`
   - Filter and format the output as JSON

5. **Present results**
   - Display the JSON output to the user
   - Interpret empty arrays as "no capabilities of this type"

6. **Clean up**
   - Remove the temporary directory and all contents
   - Use `rm -rf /tmp/tf-inspect-*` or similar

## Security

The script implements security hardening to prevent command injection:

- **Input validation**: Provider names restricted to alphanumeric, hyphens, and underscores
- **Safe string handling**: All provider operations use jq's `--arg` to prevent injection

**Security considerations:**
- Only run on trusted Terraform configurations
- Review `.tf` files before running `terraform init`
- Provider binaries are downloaded from configured registries during `terraform init`

## Capability Types

- `resources` - Standard managed resources
- `data-sources` - Read-only data sources
- `actions` - Imperative lifecycle actions
- `list` - List resource capabilities
- `ephemeral` - Ephemeral resources (credentials, tokens)
- `functions` - Provider-specific functions

## Examples

### Check Google provider for actions
```bash
# In temporary directory with provider config:
/path/to/skill/scripts/check.sh actions google
```

### Check AWS ephemeral resources
```bash
/path/to/skill/scripts/check.sh ephemeral aws
```

### Check Azure data sources
```bash
/path/to/skill/scripts/check.sh data-sources azurerm
```

### Check all configured providers for a capability
```bash
# Omit provider name to check all:
/path/to/skill/scripts/check.sh functions
```

## Output Format

Returns JSON mapping providers to their supported capabilities:

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

## Requirements

- Terraform CLI installed
- jq (JSON processor)

## Notes

- **Always use the `check.sh` script** - it handles initialization, validation, and cleanup automatically
- The script requires a Terraform configuration file in the working directory
- Work in a temporary directory to avoid polluting the user's workspace
- Provider schemas are fetched during `terraform init` (handled by the script)
- Empty arrays in output mean the provider has no capabilities of that type
