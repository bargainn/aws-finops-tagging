output "cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "deploy_role_arn" {
  description = "Set this as the AWS_DEPLOY_ROLE_ARN variable in the GitHub repository."
  value       = aws_iam_role.deploy.arn
}
