output "tag_policy_arn" {
  description = "ARN of the tag policy attached to the AWS Organisation root."
  value       = aws_organizations_policy.mandatory_tags.arn
}

output "anomaly_monitor_arn" {
  description = "ARN of the AWS Cost Anomaly Monitor watching total service spend."
  value       = aws_ce_anomaly_monitor.total_spend.arn
}

output "budget_id" {
  description = "ID of the monthly AWS Budget resource."
  value       = aws_budgets_budget.monthly.id
}

output "active_cost_allocation_tags" {
  description = "Tag keys activated in AWS Cost Explorer for cost-allocation reporting."
  value       = [for k, v in aws_ce_cost_allocation_tag.mandatory : k]
}
