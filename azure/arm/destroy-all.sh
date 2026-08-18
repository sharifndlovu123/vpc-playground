#!/usr/bin/env bash
set -euo pipefail

# WARNING: deletes the entire resource group, including anything in it
# that this template did not create. Use destroy.sh instead if the RG
# is shared with other resources.

RESOURCE_GROUP="${1:-${RESOURCE_GROUP:?Set RESOURCE_GROUP env var or pass as first arg}}"

az group delete \
  --name "$RESOURCE_GROUP" \
  --yes
