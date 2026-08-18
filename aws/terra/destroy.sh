#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

AWS_PROFILE="${1:-${AWS_PROFILE:-}}"
if [[ -n "$AWS_PROFILE" ]]; then
  export AWS_PROFILE
fi

terraform destroy
