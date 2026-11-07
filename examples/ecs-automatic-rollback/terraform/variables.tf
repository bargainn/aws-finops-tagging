variable "name" {
  description = "Name prefix for the cluster, service and alarm."
  type        = string
  default     = "ecs-rollback-example"
}

variable "image" {
  description = "Container image for the first deployment. The pipeline replaces it on every deploy."
  type        = string
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "private_subnet_ids" {
  description = "Private subnets for the tasks."
  type        = list(string)
}

variable "task_security_group_id" {
  description = "Security group for the tasks. It must allow the load balancer to reach container_port."
  type        = string
}

variable "target_group_arn" {
  description = "Existing Application Load Balancer target group the service registers with."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "arn_suffix of that target group, used by the CloudWatch alarm."
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "arn_suffix of the Application Load Balancer, used by the CloudWatch alarm."
  type        = string
}

variable "alarm_threshold" {
  description = "Target 5xx responses per minute that count as a failed release. Set it above your normal level."
  type        = number
  default     = 10
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the deploy role, as owner/name."
  type        = string
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_oidc_provider_arn" {
  description = "ARN of the existing IAM OIDC provider for token.actions.githubusercontent.com."
  type        = string
}
