#!/bin/bash
# Read Terraform provider schema capabilities
# Usage: ./check.sh [resources|data-sources|actions|list|ephemeral|functions] [provider_name]
#
# IMPORTANT: This script expects terraform to already be initialized.
# The agent should run 'terraform init' before calling this script.

set -e

TYPE=${1:-resources}
PROVIDER=$2

# Validate capability type
case "$TYPE" in
  resources|data-sources|actions|list|ephemeral|functions) ;;
  *)
    echo "Usage: $0 [resources|data-sources|actions|list|ephemeral|functions] [provider_name]" >&2
    exit 1
    ;;
esac

# Validate provider name (alphanumeric, hyphens, underscores only, max 64 chars)
if [ -n "$PROVIDER" ]; then
  if ! [[ "$PROVIDER" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
    echo "Error: Invalid provider name. Only alphanumeric characters, hyphens, and underscores allowed (max 64 chars)." >&2
    exit 1
  fi
fi

# Check dependencies
if ! command -v jq &> /dev/null; then
  echo "Error: jq not found. Install from https://stedolan.github.io/jq/download/" >&2
  exit 1
fi

# Verify terraform is initialized
if [ ! -d ".terraform" ]; then
  echo "Error: Terraform not initialized. Run 'terraform init' first." >&2
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
esac

# Read schema (read-only operation)
SCHEMA_JSON=$(terraform providers schema -json)

if [ -n "$PROVIDER" ]; then
  # Use jq for all string operations to prevent injection
  provider_key=$(echo "$SCHEMA_JSON" | jq -r --arg prov "$PROVIDER" '
    .provider_schemas | keys[] | select(endswith("/" + $prov))
  ' || true)
  
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
