#!/usr/bin/env bash

# get key ids
aws ec2 describe-key-pairs --filters Name=key-name,Values=[ec2-key-name,bastion-key-name] --query KeyPairs[*].KeyPairId --output text --profile eo-user-devbridge

# pull key values from AWS Secrets Manager

aws ssm get-parameter --name /ec2/keypair/key-05abb699beEXAMPLE --with-decryption --query Parameter.Value --output text > bastion-key-pair.pem
aws ssm get-parameter --name /ec2/keypair/key-05abwdaubeEXAMPLE --with-decryption --query Parameter.Value --output text > ec2-key-pair.pem
