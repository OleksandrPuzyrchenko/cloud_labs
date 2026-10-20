output "application_endpoints" {
  description = "Public HTTP endpoints for the application and API documentation"
  value = {
    base_url       = "http://${aws_lb.main.dns_name}"
    health_check   = "http://${aws_lb.main.dns_name}/health"
    swagger_ui     = "http://${aws_lb.main.dns_name}/api-docs"
    test_alarm_url = "http://${aws_lb.main.dns_name}/api/simulate-error"
  }
}

output "observability" {
  description = "CloudWatch monitoring dashboard and alerting resources"
  value = {
    dashboard_name = aws_cloudwatch_dashboard.ops_dashboard.dashboard_name
    dashboard_url  = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.ops_dashboard.dashboard_name}"
    alerts_topic   = aws_sns_topic.ops_alerts.arn
    log_group      = aws_cloudwatch_log_group.ecs_logs.name
  }
}

output "database" {
  description = "Managed PostgreSQL connection coordinates"
  value = {
    address       = aws_db_instance.postgres.address
    port          = aws_db_instance.postgres.port
    database_name = aws_db_instance.postgres.db_name
  }
}

output "ci_cd_deployment" {
  description = "AWS IAM and ECR details utilized by GitHub Actions"
  value = {
    ecr_repo_url    = aws_ecr_repository.api.repository_url
    github_role_arn = aws_iam_role.github_actions_role.arn
    ecs_cluster     = aws_ecs_cluster.main.name
    ecs_service     = aws_ecs_service.api.name
  }
}

