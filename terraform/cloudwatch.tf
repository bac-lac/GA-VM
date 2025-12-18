resource "aws_cloudwatch_metric_alarm" "ga_cw_db_cpu_alarm" {
  alarm_name                = "MySQL ${var.ENV} High CPU Utilization"
  comparison_operator       = "GreaterThanThreshold"
  alarm_actions             = [aws_sns_topic.ga_sns_topic.arn]
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  statistic                 = "Maximum"
  dimensions = {
    DBInstanceIdentifier  = aws_db_instance.ga_mysql.identifier
  }
  period                    = 60
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  threshold                 = 90
  treat_missing_data        = "missing"
  alarm_description         = "This metric monitors RDS ${var.ENV} cpu utilization"
}

resource "aws_cloudwatch_metric_alarm" "ga_cw_db_memory_alarm" {
  alarm_name                = "MySQL ${var.ENV} High Memory Utilization"
  comparison_operator       = "LessThanOrEqualToThreshold"
  alarm_actions             = [aws_sns_topic.ga_sns_topic.arn]
  insufficient_data_actions = []
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/RDS"
  statistic                 = "Minimum"
  dimensions = {
    DBInstanceIdentifier  = aws_db_instance.ga_mysql.identifier
  }
  period                    = 60
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  threshold                 = floor(var.DB_INSTANCE_CLASS_MEMORY * 1024 * 1024 * 1024 * 0.10)
  treat_missing_data        = "missing"
  alarm_description         = "This metric monitors RDS ${var.ENV} memory utilization"
}

resource "aws_cloudwatch_metric_alarm" "ga_cw_db_drive_alarm" {
  alarm_name                = "MySQL ${var.ENV} drive usage reaching 90%"
  comparison_operator       = "LessThanThreshold"
  alarm_actions             = [aws_sns_topic.ga_sns_topic.arn]
  insufficient_data_actions = []
  metric_name               = "FreeStorageSpace"
  namespace                 = "AWS/RDS"
  statistic                 = "Minimum"
  dimensions = {
    DBInstanceIdentifier  = aws_db_instance.ga_mysql.identifier
  }
  period                    = 60
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  threshold                 = floor(aws_db_instance.ga_mysql.allocated_storage * 1024 * 1024 * 1024 * 0.10)
  treat_missing_data        = "missing"
  alarm_description         = "This metric monitors RDS ${var.ENV} drive usage reaching 90%"
}

/* resource "aws_cloudwatch_metric_alarm" "ga_cw_nlb_22_alarm" {
  alarm_name                = "NLB port 22 ${var.ENV} unhealthy host"
  comparison_operator       = "LessThanThreshold"
  alarm_actions             = [aws_sns_topic.ga_sns_topic.arn]
  insufficient_data_actions = []
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/NetworkELB"
  statistic                 = "Minimum"
  dimensions                = zipmap(["TargetGroup", "LoadBalancer"], [aws_lb_target_group.ga_tg_22.arn_suffix, data.aws_lb.ga_nlb.arn_suffix])
  period                    = 60
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  threshold                 = 1
  treat_missing_data        = "missing"
  alarm_description         = "This metric monitors NLB port 22 ${var.ENV} health"
}

resource "aws_cloudwatch_metric_alarm" "ga_cw_alb_443_alarm" {
  alarm_name                = "ALB port 443 ${var.ENV} unhealthy host"
  comparison_operator       = "LessThanThreshold"
  alarm_actions             = [aws_sns_topic.ga_sns_topic.arn]
  insufficient_data_actions = []
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Minimum"
  dimensions                = zipmap(["TargetGroup", "LoadBalancer"], [aws_lb_target_group.ga_tg_443.arn_suffix, data.aws_lb.ga_alb.arn_suffix])
  period                    = 60
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  threshold                 = 1
  treat_missing_data        = "missing"
  alarm_description         = "This metric monitors ALB port 443 ${var.ENV} health"
}

resource "aws_cloudwatch_metric_alarm" "ga_cw_alb_8443_alarm" {
  alarm_name                = "ALB port 8443 ${var.ENV} unhealthy host"
  comparison_operator       = "LessThanThreshold"
  alarm_actions             = [aws_sns_topic.ga_sns_topic.arn]
  insufficient_data_actions = []
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Minimum"
  dimensions                = zipmap(["TargetGroup", "LoadBalancer"], [aws_lb_target_group.ga_tg_8443.arn_suffix, data.aws_lb.ga_alb.arn_suffix])
  period                    = 60
  evaluation_periods        = 5
  datapoints_to_alarm       = 5
  threshold                 = 1
  treat_missing_data        = "missing"
  alarm_description         = "This metric monitors ALB port 8443 ${var.ENV} health"
} */