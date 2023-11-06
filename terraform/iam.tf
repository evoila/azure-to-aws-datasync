resource "aws_iam_role" "kms-cmk-admin-role" {
  name               = "kms-cmk-role-admin-${var.env}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "${local.account_id}"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "kms-cmk-usage-role" {
  name               = "kms-cmk-role-usage-${var.env}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "${local.account_id}"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "kms-cmk-iam-role" {
  name               = "kms-cmk-role-${var.env}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "${local.account_id}"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "datasync-s3-access-role" {
  name               = "datasync-s3-access-role-${var.env}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "datasync.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${local.account_id}"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:datasync:${var.region}:${local.account_id}:*"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "datasync-s3-access-policy" {
  name   = "datasync-s3-access-policy-${var.datasync_agent["name"]}-${var.env}"
  role   = aws_iam_role.datasync-s3-access-role.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}"
        },
        {
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:ListMultipartUploadParts",
                "s3:PutObjectTagging",
                "s3:GetObjectTagging",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
        }
    ]
}
  EOF
}


resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_document = data.aws_iam_policy_document.cloudwatch_log_group.json
  policy_name     = "datasync-clw-policy-${var.datasync_agent["name"]}-${var.env}"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "datasync-${var.datasync_agent["name"]}-${var.env}"
  retention_in_days = 14
}
