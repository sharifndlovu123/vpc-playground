#!/usr/bin/env bash

# ensure your AWS CLI is configured with the correct profile and region
aws cloudformation delete-stack --stack-name my-vpc-stack 