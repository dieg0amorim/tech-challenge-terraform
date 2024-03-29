resource "aws_cloudwatch_log_group" "example" {
  name              = "tech-challenge-log-group"
  retention_in_days = 7
}