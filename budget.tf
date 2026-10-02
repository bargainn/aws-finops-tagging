/**
 * AWS Budgets — monthly spend ceiling with email alerts.
 *
 * Creates a cost budget and SNS-backed alert. The budget tracks
 * actual monthly spend; the alert fires when spend reaches
 * budget_alert_threshold % of budget_limit_usd.
 */

resource "aws_budgets_budget" "monthly" {
  name         = "${var.policy_name_prefix}-monthly-spend"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.budget_alert_threshold
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }
}
