# Example: automatic ECS rollback with GitHub Actions

A small, copyable example of automatic rollback for Amazon ECS with GitHub Actions:

- The ECS deployment circuit breaker, with rollback, in Terraform.
- CloudWatch alarm rollback on target 5xx errors.
- A GitHub Actions workflow that signs in with OIDC (no stored AWS keys) and **fails the job if ECS rolled back**, which the deploy action alone does not do.

It accompanies two guides on the Keel blog:

- [How do you roll back a failed ECS deployment automatically with GitHub Actions?](https://trykeel.co.uk/blog/ecs-automatic-rollback-github-actions/)
- [How do you roll back an ECS deployment when database migrations already ran?](https://trykeel.co.uk/blog/ecs-rollback-after-database-migration/)

## Status

The configuration was checked against the current AWS, GitHub and Terraform provider documentation. It has **not been applied or run in a test AWS account yet**, and `terraform validate` has not been run. Treat it as a starting point, run it in a non-production account first, and read `terraform plan` before you apply.

## What is in here

| Path | What it is |
| --- | --- |
| `terraform/` | ECS cluster, task definition, service with circuit breaker and alarm rollback, the 5xx alarm and a GitHub OIDC deploy role |
| `workflows/deploy.yml` | Copy to `.github/workflows/` in your own repository. Build, push, deploy, then verify the service is running the new task definition |
| `.aws/task-definition.json` | Task definition the workflow renders with the new image |
| `Dockerfile` | Placeholder app that answers 200 on port 8080. Replace it |

## Before you use it

You need an existing VPC with private subnets, an Application Load Balancer with a target group, a security group for the tasks, an ECR repository named after `var.name`, and the IAM OIDC provider for `token.actions.githubusercontent.com`. The Terraform takes those as inputs. Nothing account specific is hardcoded.

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill it in (see below).
2. `terraform init && terraform plan`, then apply in a test account.
3. Set the repository variable `AWS_DEPLOY_ROLE_ARN` to the `deploy_role_arn` output.
4. Put the execution role ARN in `.aws/task-definition.json` and adjust the region and names at the top of the workflow.
5. Deploy a known-good image first. The circuit breaker needs an earlier completed deployment to roll back to.
6. Prove it works: deploy an image whose health endpoint fails and check that ECS rolls back and the workflow goes red.

## terraform.tfvars.example

```hcl
image                    = "<account-id>.dkr.ecr.eu-west-2.amazonaws.com/ecs-rollback-example:initial"
private_subnet_ids       = ["subnet-aaaa", "subnet-bbbb"]
task_security_group_id   = "sg-0123456789abcdef0"
target_group_arn         = "arn:aws:elasticloadbalancing:..."
target_group_arn_suffix  = "targetgroup/example/0123456789abcdef"
load_balancer_arn_suffix = "app/example/0123456789abcdef"
github_repository        = "your-org/your-repo"
github_oidc_provider_arn = "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
```

## Known limits

- Rolling back the containers does not undo database migrations. Make migrations backward compatible (expand and contract) as described in the second guide.
- Alarm rollback only sees the metric you chose. Tune `alarm_threshold` to your normal error level.
- The circuit breaker and alarm rollback apply to services using the ECS rolling update deployment controller.

## Licence

Same licence as this repository.

Maintained by [Keel](https://trykeel.co.uk), a managed AWS operations service for SaaS teams. If you would rather not run this yourself, see the [Startup programme](https://trykeel.co.uk/#pricing).
