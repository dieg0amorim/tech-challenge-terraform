resource "aws_cloudwatch_log_group" "example" {
  name              = "techchallenge3-log-group"
  retention_in_days = 7
}