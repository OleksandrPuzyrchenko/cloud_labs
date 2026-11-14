resource "aws_cloudwatch_dashboard" "autoscaling" {
  dashboard_name = "cloud-lab-autoscaling"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 5
        properties = {
          title  = "1. Екземпляри: бажана і фактична кількість"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Maximum"
          metrics = [
            ["ECS/ContainerInsights", "DesiredTaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.api.name, { label = "Бажана (desired)" }],
            ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.api.name, { label = "Фактична (running)" }]
          ]
          yAxis = { left = { min = 0, max = 5 } }
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 5
        properties = {
          title  = "2. Завантаження CPU, % (поріг масштабування 60%)"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.api.name, { label = "CPU %" }]
          ]
          annotations = {
            horizontal = [{ label = "Ціль 60%", value = 60, color = "#d62728" }]
          }
          yAxis = { left = { min = 0, max = 100 } }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 5
        properties = {
          title  = "3. Запити за хвилину"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix, { label = "Запитів/хв" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 5
        width  = 12
        height = 5
        properties = {
          title  = "4. Латентність p95, с"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "p95"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { label = "p95" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 5
        width  = 12
        height = 5
        properties = {
          title  = "5. Відповіді 5xx"
          view   = "timeSeries"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { label = "5xx", color = "#d62728" }]
          ]
        }
      }
    ]
  })
}