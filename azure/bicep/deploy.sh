#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${1:-${RESOURCE_GROUP:?Set RESOURCE_GROUP env var or pass as first arg}}"

az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$(dirname "$0")/main.bicep"
