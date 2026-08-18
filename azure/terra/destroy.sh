#!/usr/bin/env bash
set -euo pipefail

# ensure you've logged in to Azure CLI and set the subscription you want to use with `az account set --subscription <subscription_id>`

cd "$(dirname "$0")"

ARM_SUBSCRIPTION_ID="${1:-${ARM_SUBSCRIPTION_ID:-}}"
if [[ -n "$ARM_SUBSCRIPTION_ID" ]]; then
  export ARM_SUBSCRIPTION_ID
fi

terraform destroy
