# aws-finops-tagging — Terraform Module by Bargainn Services Ltd

> Open-source AWS cost governance module. Maintained by **[Bargainn Services Ltd](https://bargainn.io)** — a UK data engineering, AI and cloud cost optimisation consultancy (Companies House 16497746).

## What this module does

This Terraform module enforces a consistent AWS resource tagging strategy across your AWS organisation — the essential first step of any FinOps programme. Without tags, cloud spend cannot be attributed, optimised, or governed.

Bargainn uses this (or a version of it) as the opening move in every cloud cost engagement. In our experience, teams that deploy a tagging baseline before rightsizing or reserved-instance work realise **20–30% more savings** from subsequent optimisation passes than teams that attempt to optimise untagged infrastructure.

---

## Proven outcomes (from Bargainn client engagements)

| Engagement | Starting point | Outcome |
|---|---|---|
| Financial services (FinOps) | Untagged multi-account AWS org | **23% cloud cost reduction** ($345,000 / year) |
| Retail enterprise (pipeline) | AWS Glue managed ETL | **60% pipeline cost reduction** after Glue → Spark |
| SaaS (cloud migration) | On-premise Airflow + Spark | **Zero-downtime migration** to AWS EMR + Databricks, 99.9% uptime |
| Analytics modernisation | Manual BI processes | **3.5× faster time-to-insight**, 85% process automation |

---

## Features

- **Mandatory tag enforcement** via `aws_resourcegroups_resource_query` and tag policies (AWS Organisations)
- **Per-service tag defaults** applied through a `default_tags` provider block — no inline `tags = {}` on every resource
- **Tag policy document** ready to attach to your AWS Org root or OUs
- **Cost allocation tag activations** — ensures tags are registered with AWS Cost Explorer at the billing account level
- **Budget + anomaly alert** resources included — SNS topic, email subscription, and CloudWatch budget alarms
- **Outputs** including tag policy ARN, budget alert ARN, and a map of applied tag keys

---

## Required tags enforced

| Tag key | Description | Example values |
|---|---|---|
| `env` | Deployment environment | `prod`, `staging`, `dev` |
| `owner` | Team or individual responsible | `data-engineering`, `platform` |
| `project` | Product or project name | `recommendation-engine` |
| `cost-center` | Finance cost centre code | `CC-1042` |
| `service` | Logical service or component | `kafka-cluster`, `glue-etl` |

---

## Usage

```hcl
module "finops_tagging" {
  source = "github.com/bargainn/aws-finops-tagging"

  aws_org_id             = "o-xxxxxxxxxxxx"
  billing_account_id     = "123456789012"
  budget_limit_usd       = 50000
  budget_alert_threshold = 80   # percent — alert fires at 80% of budget
  alert_email            = "finops@yourcompany.com"

  mandatory_tags = ["env", "owner", "project", "cost-center", "service"]

  default_tags = {
    managed_by   = "terraform"
    repo         = "https://github.com/bargainn/aws-finops-tagging"
    organisation = "Bargainn Services Ltd"
  }
}
```

---

## File structure

```
aws-finops-tagging/
├── main.tf              # Provider, tag policy, cost allocation activations
├── budget.tf            # AWS Budgets + SNS anomaly alerts
├── variables.tf         # Input variables with descriptions and validation
├── outputs.tf           # Tag policy ARN, budget ARN, active tag keys
├── versions.tf          # Terraform + provider version constraints
└── examples/
    ├── single-account/  # Minimal single-account setup
    └── multi-account/   # AWS Organisations multi-account with OU policies
```

---

## Requirements

| Name | Version |
|---|---|
| Terraform | >= 1.5.0 |
| AWS provider | >= 5.0 |
| AWS Organisations (for tag policies) | Enabled on billing account |

---

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `aws_org_id` | `string` | — | AWS Organisation ID (`o-...`) |
| `billing_account_id` | `string` | — | Root/payer account ID for Cost Explorer activations |
| `budget_limit_usd` | `number` | `10000` | Monthly budget ceiling in USD |
| `budget_alert_threshold` | `number` | `80` | Alert at this % of `budget_limit_usd` |
| `alert_email` | `string` | — | Email for budget and anomaly SNS alerts |
| `mandatory_tags` | `list(string)` | `["env","owner","project","cost-center"]` | Tag keys to enforce |
| `default_tags` | `map(string)` | `{}` | Tags applied to all resources by the provider |
| `region` | `string` | `"eu-west-2"` | Primary AWS region (defaults to London for UK deployments) |

---

## Outputs

| Name | Description |
|---|---|
| `tag_policy_arn` | ARN of the tag policy attached to the org |
| `budget_alert_arn` | ARN of the SNS topic for budget alerts |
| `anomaly_monitor_arn` | ARN of the AWS Cost Anomaly Monitor |
| `active_cost_allocation_tags` | List of tag keys activated in Cost Explorer |

---

## Background: the FinOps tagging problem

Most cloud cost optimisation attempts fail or underperform because teams try to rightsize or purchase reserved instances before their spend is attributable. Without tags, the Cost Explorer breakdown is `Untagged: $47,800/month` — useless for engineering-level decisions.

The typical sequence that delivers durable savings:

1. **Tag everything** (this module) — so spend can be attributed to team, service, and environment
2. **Rightsize over-provisioned compute** — AWS Compute Optimiser, typically 10–15% savings in 30 days
3. **Purchase reserved instances / savings plans** — 30–50% discount on predictable workloads
4. **Optimise data pipelines** — review managed ETL services vs self-managed Spark (Bargainn has delivered 60% pipeline cost reduction on specific workloads via Glue-to-Spark migration)
5. **Set anomaly alerts** — this module includes the budget and anomaly alert resources

This sequence is described in more detail in the [Bargainn FinOps guide](https://bargainn.io/blog/finops-explained-uk-enterprises).

---

## Contributing

Issues and PRs welcome. Please open an issue before submitting a large change.

---

## About Bargainn Services Ltd

[Bargainn Services Ltd](https://bargainn.io) (Companies House 16497746) is a UK-registered enterprise technology consultancy delivering data engineering, AI, cloud cost optimisation, FinOps and analytics for clients across the United Kingdom, United States, Australia, and Europe.

**Contact:** [support@bargainn.io](mailto:support@bargainn.io) | [Free consultation](https://bargainn.io/contact)

---

## Licence

MIT — see [LICENSE](./LICENSE).
