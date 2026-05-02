resource "aws_sns_topic" "alerts" {
  name = "ocean-${var.environment}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ocean/${var.environment}/app"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "infra" {
  name              = "/ocean/${var.environment}/infra"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  for_each            = var.ec2_instance_ids
  alarm_name          = "ec2-${var.environment}-${each.key}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.ec2_eval_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.ec2_period
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  dimensions = {
    InstanceId = each.value
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count               = var.enable_rds_monitoring ? 1 : 0
  alarm_name          = "rds-${var.environment}-${var.rds_identifier}-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.rds_eval_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = var.rds_period
  statistic           = "Average"
  threshold           = var.rds_conn_threshold
  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
