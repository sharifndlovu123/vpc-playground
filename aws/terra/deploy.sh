#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Which config to run: bootstrap (state bucket, one-time) or an env under
# envs/ (e.g. prod). Defaults to prod since that's the day-to-day config.
TARGET="${1:-prod}"
AWS_PROFILE="${2:-${AWS_PROFILE:-}}"

if [[ "$TARGET" == "bootstrap" ]]; then
  DIR="bootstrap"
else
  DIR="envs/$TARGET"
fi

if [[ ! -d "$DIR" ]]; then
  echo "No such config: $DIR" >&2
  exit 1
fi

if [[ -n "$AWS_PROFILE" ]]; then
  export AWS_PROFILE
fi

cd "$DIR"

# init downloads providers and writes/reads .terraform.lock.hcl,
# pinning exact provider versions so plan/apply are reproducible.
terraform init

terraform plan -out=tfplan

terraform apply tfplan
