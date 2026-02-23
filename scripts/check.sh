#!/bin/bash
# Extract Terraform provider capabilities
# Usage: ./check.sh [resources|data-sources|actions|list|ephemeral|functions] [provider_name]

set -e

TYPE=${1:-resources}
PROVIDER=$2

# Check dependencies
if ! command -v terraform &> /dev/null; then
  echo "Error: terraform CLI not found. Install from https://www.terraform.io/downloads" >&2
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq not found. Install from https://stedolan.github.io/jq/download/" >&2
  exit 1
fi

# Check for Terraform configuration
TF_FILES=$(ls *.tf 2>/dev/null | wc -l | tr -d ' ')
if [ "$TF_FILES" -eq 0 ] && [ ! -f ".terraform.lock.hcl" ]; then
  echo "Error: No Terraform configuration found." >&2
  echo "Please create a providers.tf file with the provider configuration." >&2
  echo "" >&2
  echo "Example for AWS:" >&2
  echo "  terraform {" >&2
  echo "    required_providers {" >&2
  echo "      aws = {" >&2
  echo "        source = \"hashicorp/aws\"" >&2
  echo "      }" >&2
  echo "    }" >&2
  echo "  }" >&2
  exit 1
fi

# Map type to schema key
case "$TYPE" in
  resources) SCHEMA_KEY="resource_schemas" ;;
  data-sources) SCHEMA_KEY="data_source_schemas" ;;
  actions) SCHEMA_KEY="action_schemas" ;;
  list) SCHEMA_KEY="list_resource_schemas" ;;
  ephemeral) SCHEMA_KEY="ephemeral_resource_schemas" ;;
  functions) SCHEMA_KEY="functions" ;;
  *)
    echo "Usage: $0 [resources|data-sources|actions|list|ephemeral|functions] [provider_name]" >&2
    exit 1
    ;;
esac

terraform init -upgrade > /dev/null 2>&1

SCHEMA_JSON=$(terraform providers schema -json)

if [ -n "$PROVIDER" ]; then
  provider_key=$(echo "$SCHEMA_JSON" | jq -r '.provider_schemas | keys[]' | grep "/${PROVIDER}$" || true)
  if [ -n "$provider_key" ]; then
    echo "$SCHEMA_JSON" | jq -r --arg pk "$provider_key" --arg sk "$SCHEMA_KEY" --arg prov "$PROVIDER" '
      .provider_schemas[$pk][$sk] // {} |
      if . == {} then [] else keys | sort end |
      {($prov): .}
    '
  else
    jq -n --arg prov "$PROVIDER" '{($prov): []}'
  fi
else
  echo "$SCHEMA_JSON" | jq -r --arg sk "$SCHEMA_KEY" '
    .provider_schemas | to_entries |
    map({
      key: (.key | split("/")[-1]),
      value: ((.value[$sk] // {}) | if . == {} then [] else keys | sort end)
    }) |
    from_entries
  '
fi
