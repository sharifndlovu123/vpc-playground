#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

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

terraform destroy
