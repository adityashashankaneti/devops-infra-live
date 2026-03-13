# devops-infra-live

Infrastructure-as-Code repository managed by **DevOps AI**.

## Architecture

Uses **reusable Terraform modules** + **Terragrunt** + **YAML resource configs**.

Each resource type has a pre-built Terraform module under `modules/`.
Projects are deployed under `environments/<project>/`, with per-resource-type
subdirectories containing a `terragrunt.hcl` (pointing at the module) and a
`resources.yaml` (listing resource instances and their config).

## How it works

1. **DevOps AI Frontend** → User designs architecture on canvas
2. **DevOps AI Backend** (Lambda) → Claude classifies resources into per-module YAML configs
3. **Lambda** → Appends/merges resources into `resources.yaml` files, creates PR
4. **GitHub Actions** → Runs `terragrunt run-all plan` on PR, `terragrunt run-all apply` on merge

## Structure

```
devops-infra-live/
├── modules/                        ← Reusable Terraform modules
│   ├── vpc/                        ← VPC module (for_each over resources map)
│   ├── subnet/
│   ├── ec2/
│   ├── security-group/
│   ├── s3/
│   ├── rds/
│   ├── lambda/
│   ├── alb/
│   ├── eventbridge/
│   ├── sqs/
│   ├── sns/
│   ├── dynamodb/
│   ├── route53/
│   ├── ecs/
│   ├── cloudfront/
│   ├── elasticache/
│   ├── internet-gateway/
│   └── nat-gateway/
├── environments/
│   ├── terragrunt.hcl              ← Root config (remote state, provider)
│   └── <project>/                  ← Per-project directory
│       ├── project.yaml            ← Project name + region
│       ├── vpc/
│       │   ├── terragrunt.hcl      ← Points at modules//vpc
│       │   └── resources.yaml      ← VPC instances + config
│       ├── ec2/
│       │   ├── terragrunt.hcl
│       │   └── resources.yaml
│       └── ...
├── .github/workflows/
│   └── terraform.yml               ← CI/CD: plan on PR, apply on merge
└── README.md
```

## YAML Resource Format

Each `resources.yaml` is a map of resource_name → config:

```yaml
# environments/my-infra/ec2/resources.yaml
my-web-server:
  instance_type: t3.micro
  ami: ami-0c7217cdde317cfec
  subnet_name: public-subnet-1
  security_groups:
    - web-sg
  associate_public_ip_address: true

my-api-server:
  instance_type: t3.small
  ami: ami-0c7217cdde317cfec
  subnet_name: private-subnet-1
  security_groups:
    - api-sg
```

Adding a new resource = appending to this YAML file → triggers CD.

## Cross-Resource References

Resources reference each other by **name** (not ID):
- Subnets use `vpc_name` to reference a VPC
- EC2 uses `subnet_name` + `security_groups` (list of SG names)
- Terragrunt `dependency` blocks wire outputs between modules

## Setup

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key for Terraform |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for Terraform |
| `AWS_REGION` | Default AWS region (e.g. `us-east-1`) |

### Terraform State

State is stored in S3 with DynamoDB locking (configured in root `terragrunt.hcl`).

```bash
aws s3 mb s3://my-infra-tf-state --region us-east-1
aws dynamodb create-table \
  --table-name my-infra-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```
