resource "aws_appautoscaling_scheduled_action" "day" {
  name               = "cloud-lab-day-min-2"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  schedule           = "cron(0 8 * * ? *)"
  timezone           = "Europe/Kyiv"

  scalable_target_action {
    min_capacity = 2
    max_capacity = 4
  }
}

resource "aws_appautoscaling_scheduled_action" "night" {
  name               = "cloud-lab-night-min-1"
  service_namespace  = aws_appautoscaling_target.api.service_namespace
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  schedule           = "cron(0 22 * * ? *)"
  timezone           = "Europe/Kyiv"

  scalable_target_action {
    min_capacity = 1
    max_capacity = 4
  }
}

