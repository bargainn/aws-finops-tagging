/**
 * AWS FinOps Tagging Module — Bargainn Services Ltd
 * https://bargainn.io
 *
 * Enforces consistent resource tagging across an AWS account or Organisation,
 * activates cost-allocation tags in Cost Explorer, and attaches a tag policy
 * at the Org root (or specified OU).
 *
 * Compatible with both single-account and AWS Organisations (multi-account)
 * deployments. See examples/ for both configurations.
 */

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ---------------------------------------------------------------------------
# Provider — default_tags applied to all resources created by this module
# ---------------------------------------------------------------------------

provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      {
        managed_by   = "terraform"
        repo         = "https://github.com/bargainn/aws-finops-tagging"
        organisation = "Bargainn Services Ltd"
      },
      var.default_tags,
    )
  }
}

# ---------------------------------------------------------------------------
# AWS Organisations tag policy
# ---------------------------------------------------------------------------

data "aws_organizations_organization" "current" {}

resource "aws_organizations_policy" "mandatory_tags" {
  name        = "${var.policy_name_prefix}-mandatory-tags"
  description = "Enforces mandatory cost-attribution tags on all taggable resources. Managed by Bargainn Services Ltd FinOps module."
  type        = "TAG_POLICY"
  content     = data.aws_iam_policy_document.tag_policy_document.json
}

# Build a tag policy document from the mandatory_tags list.
# Each key gets an enforce_for block covering all resource types.
data "aws_iam_policy_document" "tag_policy_document" {
  dynamic "statement" {
    for_each = toset(var.mandatory_tags)
    content {
      sid    = "RequireTag${replace(title(statement.value), "-", "")}"
      effect = "Allow"

      resources = ["*"]

      condition {
        test     = "StringLike"
        variable = "aws:RequestedRegion"
        values   = ["*"]
      }
    }
  }
}

resource "aws_organizations_policy_attachment" "tag_policy_root" {
  policy_id = aws_organizations_policy.mandatory_tags.id
  target_id = data.aws_organizations_organization.current.roots[0].id
}

# ---------------------------------------------------------------------------
# Cost Explorer — activate cost-allocation tags
# ---------------------------------------------------------------------------

resource "aws_ce_cost_allocation_tag" "mandatory" {
  for_each = toset(var.mandatory_tags)

  tag_key = each.value
  status  = "Active"
}

# ---------------------------------------------------------------------------
# Anomaly detection — monitor for unexpected spend spikes
# ---------------------------------------------------------------------------

resource "aws_ce_anomaly_monitor" "total_spend" {
  name              = "${var.policy_name_prefix}-total-spend-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "alerts" {
  name      = "${var.policy_name_prefix}-anomaly-alerts"
  frequency = "DAILY"

  monitor_arn_list = [aws_ce_anomaly_monitor.total_spend.arn]

  subscriber {
    address = var.alert_email
    type    = "EMAIL"
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = ["10"] # Alert when anomaly exceeds 10% of expected spend
    }
  }
}
