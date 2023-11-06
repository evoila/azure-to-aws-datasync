output "cloudwatch_log_group_arn" {
  value = join(",", split(":*", aws_cloudwatch_log_group.this.arn))
}
