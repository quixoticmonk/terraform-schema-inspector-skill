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

When a user asks about provider capabilities:

1. **Check for existing Terraform configuration**
   - Look for `*.tf` files or `.terraform.lock.hcl` in the current directory
   - If found, skip to step 3

2. **Create provider configuration** (if needed)
   - Create a minimal `providers.tf` file with the requested provider
   - Example for AWS:
     ```hcl
     terraform {
       required_providers {
         aws = {
           source = "hashicorp/aws"
         }
       }
     }
     ```
   - For other providers, replace `aws` with the provider name (e.g., `azurerm`, `google`, `kubernetes`)

3. **Run the inspection script**
   ```bash
   scripts/check.sh <capability_type> <provider_name>
   ```

4. **Verify execution**
   - Check the script succeeded (exit code 0)
   - Validate output is valid JSON
   - Common failures: missing `terraform` CLI, `jq` not installed, provider initialization errors, invalid provider names

5. **Clean up** (if you created the provider file)
   - Remove the temporary `providers.tf` file
   - Remove `.terraform/` directory and `.terraform.lock.hcl`

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

### Check AWS ephemeral resources
```bash
# Create providers.tf first, then:
scripts/check.sh ephemeral aws
```

### Check all providers for actions
```bash
# If multiple providers configured:
scripts/check.sh actions
```

### Check Azure data sources
```bash
# Create providers.tf with azurerm, then:
scripts/check.sh data-sources azurerm
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

- The script requires a Terraform configuration to inspect provider schemas
- Always clean up temporary files after inspection
- Provider schemas are fetched during `terraform init`
