data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch_log_group" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = ["${aws_cloudwatch_log_group.this.arn}"]
    principals {
      identifiers = ["datasync.amazonaws.com"]
      type        = "Service"
    }
  }
}
