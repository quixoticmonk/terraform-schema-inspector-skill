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

# Create minimal provider config if none exists
if [ ! -f "*.tf" ] && [ ! -f ".terraform.lock.hcl" ]; then
  cat > _temp_provider.tf <<EOF
terraform {
  required_providers {
    ${PROVIDER:-aws} = {
      source = "hashicorp/${PROVIDER:-aws}"
    }
  }
}
EOF
  CLEANUP_TEMP=1
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

if [ -n "$PROVIDER" ]; then
  provider_key=$(terraform providers schema -json | jq -r '.provider_schemas | keys[]' | grep "/${PROVIDER}$")
  if [ -n "$provider_key" ]; then
    terraform providers schema -json | jq -r "{\"$PROVIDER\": (.provider_schemas.\"${provider_key}\" | .${SCHEMA_KEY} // {} | keys | sort)}"
  else
    echo "{\"$PROVIDER\": []}"
  fi
else
  terraform providers schema -json | jq -r "
    .provider_schemas | to_entries |
    map({key: (.key | split(\"/\")[-1]), value: (.value.${SCHEMA_KEY} // {} | keys | sort)}) |
    from_entries
  "
fi

# Cleanup temp file if created
if [ -n "$CLEANUP_TEMP" ]; then
  rm -f _temp_provider.tf
fi
