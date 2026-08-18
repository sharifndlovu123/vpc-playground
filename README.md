# VPC / VNet — IaC Comparison

Same network — one VPC/VNet, a public subnet, a private subnet — built four
different ways, to compare ergonomics across clouds and tooling:

| Cloud | Tool           | Path          |
|-------|----------------|---------------|
| AWS   | CloudFormation | `aws/cfn/`    |
| AWS   | Terraform      | `aws/terra/`  |
| Azure | ARM (JSON)     | `azure/arm/`  |
| Azure | Bicep          | `azure/bicep/`|
| Azure | Terraform      | `azure/terra/`|

Each `notes.md` has the exercise prompt for that folder; each IaC folder
has its own `deploy.sh` / `destroy.sh` (plus `destroy-all.sh` where noted)
so the commands don't have to be re-remembered every time.

## Prerequisites

- `aws` CLI, configured (`aws configure` / `AWS_PROFILE`)
- `az` CLI, logged in (`az login`, `az account set --subscription <id>`)
- `terraform` (for `aws/terra/` and `azure/terra/`)
- `bicep` CLI (for `azure/bicep/`) — bundled with a recent `az` CLI

## AWS — CloudFormation (`aws/cfn/`)

VPC with public + private subnets, an Internet Gateway, and route tables,
parameterized instead of hardcoded CIDRs.

```bash
aws cloudformation deploy \
  --template-file aws/cfn/template.yml \
  --stack-name vpc-cfn-demo \
  --capabilities CAPABILITY_NAMED_IAM
```

Destroy:

```bash
aws cloudformation delete-stack --stack-name vpc-cfn-demo
```

## AWS — Terraform (`aws/terra/`)

Same VPC, built with `aws_vpc` / `aws_subnet` / `aws_internet_gateway` /
`aws_route_table`, using `cidrsubnet()` to carve subnets from a single VPC
CIDR, plus a NAT Gateway for private-subnet outbound traffic.

```bash
cd aws/terra
./deploy.sh <aws-profile>     # terraform init, plan, apply
./destroy.sh <aws-profile>    # terraform destroy (interactive confirm)
```

NAT Gateway is billed hourly — don't leave it running if you're just testing.

## Azure — ARM (`azure/arm/`)

Portal-exported ARM template (VNet, 2 subnets, NSGs, a Network Manager +
IPAM pool for address allocation), cleaned up post-export (deduped the
subnets that the exporter declares twice, parameterized the address
prefixes per subnet instead of reusing one shared range).

```bash
cd azure/arm
./deploy.sh <resource-group>        # az deployment group create
./destroy.sh <resource-group>       # deletes the named resources only
./destroy-all.sh <resource-group>   # deletes the entire resource group
```

## Azure — Bicep (`azure/bicep/`)

`bicep decompile` output from the same ARM template, hand-cleaned the same
way (deduped subnets — which also removed a circular dependency the
decompile introduced — and split the address-prefix param per subnet).

```bash
cd azure/bicep
./deploy.sh <resource-group>        # az deployment group create
./destroy.sh <resource-group>       # deletes the named resources only
./destroy-all.sh <resource-group>   # deletes the entire resource group
```

## Azure — Terraform (`azure/terra/`)

Same resources again, this time via the `azurerm` provider (imported/
exported from the same VNet), using Azure CLI auth by default.

```bash
cd azure/terra
./deploy.sh <subscription-id>     # terraform init, plan, apply
./destroy.sh <subscription-id>    # terraform destroy (interactive confirm)
```

## Notes

- All `deploy.sh`/`destroy.sh` scripts accept their identifier (resource
  group, AWS profile, or subscription ID) either as `$1` or via env var —
  whichever isn't set, the other is required.
- `destroy.sh` under `azure/arm` and `azure/bicep` removes only the
  resources the template created; `destroy-all.sh` deletes the whole
  resource group, which is faster for a disposable sandbox RG but will
  also remove anything else living in it.
