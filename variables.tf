variable "aws_org_id" {
  description = "AWS Organisation ID (o-...). Required when attaching tag policies to org root."
  type        = string
  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.aws_org_id))
    error_message = "aws_org_id must match the format o-xxxxxxxxxx."
  }
}

variable "billing_account_id" {
  description = "Root/payer AWS account ID — used for Cost Explorer cost-allocation tag activations."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.billing_account_id))
    error_message = "billing_account_id must be a 12-digit AWS account ID."
  }
}

variable "region" {
  description = "Primary AWS region. Defaults to eu-west-2 (London) for UK-first deployments."
  type        = string
  default     = "eu-west-2"
}

variable "budget_limit_usd" {
  description = "Monthly budget ceiling in USD. An alert fires when actual spend reaches budget_alert_threshold percent of this value."
  type        = number
  default     = 10000
  validation {
    condition     = var.budget_limit_usd > 0
    error_message = "budget_limit_usd must be a positive number."
  }
}

variable "budget_alert_threshold" {
  description = "Percentage of budget_limit_usd at which a budget alert email is sent (0–100)."
  type        = number
  default     = 80
  validation {
    condition     = var.budget_alert_threshold > 0 && var.budget_alert_threshold <= 100
    error_message = "budget_alert_threshold must be between 1 and 100."
  }
}

variable "alert_email" {
  description = "Email address to receive budget and anomaly alert notifications."
  type        = string
  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "mandatory_tags" {
  description = "List of tag keys to enforce via the AWS Organisations tag policy and activate in Cost Explorer."
  type        = list(string)
  default     = ["env", "owner", "project", "cost-center", "service"]
}

variable "default_tags" {
  description = "Additional tags applied to all resources by the provider default_tags block."
  type        = map(string)
  default     = {}
}

variable "policy_name_prefix" {
  description = "Name prefix for AWS Organisations policies, budget, and anomaly resources. Keep short and unique per Org."
  type        = string
  default     = "finops"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,20}$", var.policy_name_prefix))
    error_message = "policy_name_prefix must be lowercase alphanumeric with hyphens, starting with a letter, max 21 chars."
  }
}
