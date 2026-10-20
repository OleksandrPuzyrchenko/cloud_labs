resource "aws_sns_topic" "ops_alerts" {
  name         = "cloudlab-ops-notifications"
  display_name = "CloudLab API Operations Alert"
}

resource "aws_sns_topic_subscription" "ops_email_sub" {
  topic_arn = aws_sns_topic.ops_alerts.arn
  protocol  = "email"
  endpoint  = var.budget_email
}

resource "aws_cloudwatch_metric_alarm" "api_server_5xx" {
  alarm_name          = "cloudlab-api-server-5xx-spike"
  alarm_description   = "Triggers when application encounters internal 5xx errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.ops_alerts.arn]
  ok_actions    = [aws_sns_topic.ops_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_container_high_cpu" {
  alarm_name          = "cloudlab-ecs-high-cpu-utilization"
  alarm_description   = "Alerts if container CPU load exceeds 80% for 2 consecutive minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.api.name
  }

  alarm_actions = [aws_sns_topic.ops_alerts.arn]
  ok_actions    = [aws_sns_topic.ops_alerts.arn]
}

resource "aws_cloudwatch_dashboard" "ops_dashboard" {
  dashboard_name = "cloudlab-operational-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 3
        properties = {
          title  = "Requests (1h Total)"
          view   = "singleValue"
          region = var.aws_region
          period = 3600
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum", label = "HTTP Requests" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 3
        properties = {
          title  = "5xx Errors (1h Total)"
          view   = "singleValue"
          region = var.aws_region
          period = 3600
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum", label = "5xx Errors", color = "#d62728" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 3
        properties = {
          title  = "Avg Latency (seconds)"
          view   = "singleValue"
          region = var.aws_region
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Average", label = "Response Time" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 3
        properties = {
          title  = "Healthy Backend Targets"
          view   = "singleValue"
          region = var.aws_region
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", aws_lb.main.arn_suffix, "TargetGroup", aws_lb_target_group.api.arn_suffix, { stat = "Minimum", label = "Active Tasks", color = "#2ca02c" }]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 12
        height = 6
        properties = {
          title   = "HTTP Traffic Distribution by Status"
          view    = "timeSeries"
          stacked = true
          region  = var.aws_region
          period  = 60
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum", label = "2XX Success", color = "#2ca02c" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum", label = "4XX Client Errors", color = "#ff7f0e" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "Sum", label = "5XX Server Errors", color = "#d62728" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 3
        width  = 12
        height = 6
        properties = {
          title   = "Latency Percentiles (p50, p90, p99)"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "p50", label = "p50 (Median)" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "p90", label = "p90" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { stat = "p99", label = "p99 Tail" }]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 9
        width  = 12
        height = 6
        properties = {
          title   = "ECS Fargate Utilization (CPU & Memory %)"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.api.name, { stat = "Average", label = "CPU %", color = "#1f77b4" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.api.name, { stat = "Average", label = "Memory %", color = "#aec7e8" }]
          ]
          yAxis = {
            left = { min = 0, max = 100 }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 9
        width  = 12
        height = 6
        properties = {
          title   = "RDS PostgreSQL (Connections & Storage)"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          metrics = [
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.postgres.identifier, { stat = "Maximum", label = "Active DB Connections", color = "#9467bd" }],
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.postgres.identifier, { stat = "Average", label = "DB CPU %", color = "#bcbd22" }]
          ]
        }
      },

      {
        type   = "log"
        x      = 0
        y      = 15
        width  = 24
        height = 6
        properties = {
          title  = "Recent Application Logs"
          view   = "table"
          region = var.aws_region
          query  = "SOURCE '${aws_cloudwatch_log_group.ecs_logs.name}' | fields @timestamp, @message | sort @timestamp desc | limit 30"
        }
      }
    ]
  })
}
