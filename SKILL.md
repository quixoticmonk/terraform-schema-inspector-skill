---
name: terraform-schema-inspector-skill
description: Identify Terraform provider support for resources, data sources, actions, list resources, ephemeral resources, and functions. Use when checking provider capabilities or determining what's available.
license: MIT
compatibility: Requires Terraform CLI and jq
metadata:
  author: quixoticmonk
  version: "0.1.0"
---

# Terraform Schema Inspector

Identify which capabilities a Terraform provider supports:
- **Resources**: Standard managed resources
- **Data Sources**: Read-only data queries
- **Actions**: Imperative operations during lifecycle events
- **List Resources**: Resources supporting bulk list operations
- **Ephemeral Resources**: Temporary resources for credentials/tokens
- **Functions**: Provider-specific functions

## Usage

Run the extraction script with the capability type and optional provider:

```bash
# Check all providers for resources
scripts/check.sh resources

# Check specific provider for data sources
scripts/check.sh data-sources aws

# Check for actions
scripts/check.sh actions azurerm

# Check for list resources
scripts/check.sh list

# Check for ephemeral resources
scripts/check.sh ephemeral

# Check for functions
scripts/check.sh functions
```

## Output

Returns JSON mapping providers to their supported resources:

```json
{
  "aws": ["aws_instance", "aws_s3_bucket", "aws_lambda_function"],
  "azurerm": ["azurerm_resource_group", "azurerm_virtual_network"]
}
```

## Requirements

- Terraform CLI installed
- jq (JSON processor)

The script auto-generates a minimal provider configuration if none exists.
