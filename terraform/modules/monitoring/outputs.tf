output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "log_group_names" {
  value = [aws_cloudwatch_log_group.app.name, aws_cloudwatch_log_group.infra.name]
}
