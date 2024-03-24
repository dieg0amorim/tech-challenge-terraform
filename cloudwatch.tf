resource "aws_cloudwatch_log_group" "example" {
  name              = "hackathon-log-group"
  retention_in_days = 7
}