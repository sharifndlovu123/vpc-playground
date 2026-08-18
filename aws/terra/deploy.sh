#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

AWS_PROFILE="${1:-${AWS_PROFILE:-}}"
if [[ -n "$AWS_PROFILE" ]]; then
  export AWS_PROFILE
fi

# init downloads providers and writes/reads .terraform.lock.hcl,
# pinning exact provider versions so plan/apply are reproducible.
terraform init

terraform plan -out=tfplan

terraform apply tfplan
