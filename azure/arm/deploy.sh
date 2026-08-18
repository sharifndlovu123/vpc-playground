#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${1:-${RESOURCE_GROUP:?Set RESOURCE_GROUP env var or pass as first arg}}"

# $0 is the path the script was invoked
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$(dirname "$0")/template.json"
