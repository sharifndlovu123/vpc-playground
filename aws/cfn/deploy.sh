#!/usr/bin/env bash

set -e

# ensure your AWS CLI is configured with the correct profile and region
aws cloudformation deploy --template-file template.yml --stack-name my-vpc-stack
