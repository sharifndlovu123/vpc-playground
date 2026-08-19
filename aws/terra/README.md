# AWS VPC — Terraform

Learning project: a small VPC (public + private subnet, IGW, route, security
group) managed with Terraform, using a remote S3 backend for state instead of
the local `terraform.tfstate` file this started with.

## Layout

```
terra/
├── bootstrap/          # one-time: creates the S3 bucket that holds state
│   ├── versions.tf     # terraform + required_providers (no backend block --
│   │                   #   this config can't depend on the bucket it creates)
│   ├── providers.tf    # aws provider + default_tags
│   ├── variables.tf    # aws_region, aws_profile
│   ├── main.tf         # the state bucket: versioning, SSE-S3 encryption,
│   │                   #   public-access block, TLS-only bucket policy
│   └── outputs.tf      # tfstate_bucket_name
│
├── envs/
│   └── prod/            # the actual infrastructure (VPC, subnets, SG, ...)
│       ├── versions.tf  # terraform + required_providers (no backend here --
│       │                #   see backend.tf below)
│       ├── backend.tf   # backend "s3" block -- bucket name + profile are
│       │                #   literal (backend blocks can't use variables)
│       ├── providers.tf # aws provider + default_tags
│       ├── variables.tf # aws_region, aws_profile
│       ├── vpc.tf       # VPC, subnets, IGW, route, route table association
│       ├── security.tf  # security group + ingress/egress rules
│       └── outputs.tf   # vpc_id, subnet ids, igw id, route table id
│
├── deploy.sh            # ./deploy.sh [bootstrap|prod] [aws-profile]
├── destroy.sh            # ./destroy.sh [bootstrap|prod] [aws-profile]
├── .gitignore            # state files, .terraform/, plan output, *.tfvars
└── notes.md               # scratch notes from working through this
```

Each directory under `bootstrap/` and `envs/` is its own **root module** with
its own state — that's why each one needs its own `terraform init` and why
`bootstrap/` and `envs/prod/` are applied and destroyed independently of each
other. Splitting files by concern (`vpc.tf`, `security.tf`, `outputs.tf`, ...)
is a naming convention, not something Terraform enforces — it parses every
`.tf` file in a directory as one merged config regardless of filename.

## Why `bootstrap/` is separate from `envs/prod/`

A `backend "s3" { bucket = ... }` block is resolved before Terraform builds
its resource graph, so it can't reference a bucket created by that same
config — the bucket has to already exist. `bootstrap/` solves this by staying
on **local state permanently** and being applied once (or rarely, if the
bucket's own config changes). `envs/prod/` is what you run day-to-day, and
its state lives in the bucket `bootstrap/` created.

## Process: bootstrap, then prod

1. **`bootstrap/`** — create the state bucket (still local state at this point):
   ```
   ./deploy.sh bootstrap
   ```
   Note the `tfstate_bucket_name` output.

2. Put that bucket name into `envs/prod/backend.tf`'s `bucket` field.

3. **`envs/prod/`** — migrate local state into the bucket:
   ```
   cd envs/prod
   terraform init -migrate-state
   ```
   If local state has actual resources in it, Terraform asks to copy them
   into S3 — confirm, then run `terraform state list` and `terraform plan`
   to check nothing drifted. (If local state is empty, there's nothing to
   copy — the first `apply` afterward creates the state object in S3
   directly.)

4. From then on, day-to-day work happens in `envs/prod/` (or via
   `./deploy.sh prod` / `./destroy.sh prod` from the repo root), with state
   locking handled natively by S3 (`use_lockfile = true`, Terraform 1.10+ —
   no DynamoDB table needed).

## Gotcha: the backend has its own credentials

`provider "aws" { profile = var.aws_profile }` in `providers.tf` only
controls credentials for *managing resources* (the VPC, subnets, etc). The
`backend "s3" { ... }` block in `backend.tf` is a **completely separate**
AWS client — it doesn't inherit anything from the provider block, and it
can't reference `var.aws_profile` either way (backend config must be
literal values). Leave `profile` out of the backend block and Terraform
falls back to its normal credential chain (env vars, then the `[default]`
AWS CLI profile) — which is very likely not the identity you meant to use,
and shows up as a confusing 403 on `terraform init`/`plan` that has nothing
to do with IAM permissions on your intended profile. Fix: set `profile`
explicitly inside the `backend "s3" { }` block too.

## Tagging

Both providers set `default_tags` (`ManagedBy = terraform`, plus a
`Project`/`Environment` tag). Without a CloudFormation stack grouping
resources for you, this is what makes "everything Terraform created" findable
in the AWS console/CLI/Cost Explorer by tag filter.

## Scripts

```
./deploy.sh [bootstrap|prod] [aws-profile]   # init, plan, apply
./destroy.sh [bootstrap|prod] [aws-profile]  # destroy
```

Both default to `prod` if no target is given, and to `$AWS_PROFILE` (or the
provider's `profile` default) if no profile is given.
