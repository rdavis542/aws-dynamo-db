# aws-dynamo-db

Terraform project for provisioning an AWS DynamoDB table with encryption at rest, point-in-time recovery, optional DynamoDB Streams, optional TTL, Global Secondary Indexes, and autoscaling support for provisioned capacity mode.

## Features

- **Encryption at rest** — AWS-managed SSE enabled by default
- **Point-in-time recovery** — always enabled
- **Billing modes** — `PAY_PER_REQUEST` (default) or `PROVISIONED`
- **Autoscaling** — optional target-tracking autoscaling for read/write capacity (provisioned mode only)
- **TTL** — optional configurable TTL attribute
- **DynamoDB Streams** — optional, configurable view type
- **Global Secondary Indexes** — configurable list of GSIs
- **Default tags** — all resources tagged via provider `default_tags`

## Prerequisites

- Terraform >= 1.1.0
- AWS credentials with DynamoDB and Application Auto Scaling permissions
- S3 bucket `tf-state-replication-source-350726165848` for remote state

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `region` | AWS region | `us-east-2` |
| `table_name` | DynamoDB table name | `app-table` |
| `billing_mode` | `PAY_PER_REQUEST` or `PROVISIONED` | `PAY_PER_REQUEST` |
| `hash_key` | Partition key attribute name | `id` |
| `hash_key_type` | Partition key type (`S`, `N`, `B`) | `S` |
| `range_key` | Sort key attribute name (omit to disable) | `""` |
| `range_key_type` | Sort key type (`S`, `N`, `B`) | `S` |
| `read_capacity` | Provisioned read capacity units | `5` |
| `write_capacity` | Provisioned write capacity units | `5` |
| `enable_autoscaling` | Enable autoscaling (provisioned only) | `false` |
| `autoscaling_min_read_capacity` | Autoscaling min read units | `1` |
| `autoscaling_max_read_capacity` | Autoscaling max read units | `20` |
| `autoscaling_min_write_capacity` | Autoscaling min write units | `1` |
| `autoscaling_max_write_capacity` | Autoscaling max write units | `20` |
| `autoscaling_target_utilization` | Autoscaling target % | `70` |
| `ttl_attribute` | TTL attribute name (omit to disable) | `""` |
| `enable_streams` | Enable DynamoDB Streams | `false` |
| `stream_view_type` | Stream view type | `NEW_AND_OLD_IMAGES` |
| `global_secondary_indexes` | List of GSI definitions | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `table_name` | DynamoDB table name |
| `table_arn` | DynamoDB table ARN |
| `table_id` | DynamoDB table ID |
| `table_hash_key` | Partition key name |
| `table_range_key` | Sort key name |
| `table_billing_mode` | Billing mode |
| `stream_arn` | Stream ARN (if enabled) |
| `stream_label` | Stream label/timestamp (if enabled) |

## Examples

### On-demand table with sort key and TTL

```hcl
table_name     = "events"
hash_key       = "pk"
range_key      = "sk"
ttl_attribute  = "expires_at"
```

### Provisioned table with autoscaling and a GSI

```hcl
table_name         = "orders"
billing_mode       = "PROVISIONED"
hash_key           = "order_id"
read_capacity      = 10
write_capacity     = 5
enable_autoscaling = true

global_secondary_indexes = [
  {
    name            = "customer-index"
    hash_key        = "customer_id"
    hash_key_type   = "S"
    range_key       = "created_at"
    range_key_type  = "S"
    projection_type = "ALL"
  }
]
```

## CI/CD

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `tf-create.yml` | push/PR to `main`, `workflow_dispatch` | Plan on every push/PR; Apply on manual dispatch |
| `tf-destroy.yml` | `workflow_dispatch` | Destroy resources (requires typing "destroy" to confirm) |
| `tfsec.yml` | push/PR to `main`, weekly, `workflow_dispatch` | Security scanning with SARIF upload |

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
