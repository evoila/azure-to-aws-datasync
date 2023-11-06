
resource "aws_datasync_agent" "this" {
  ip_address = var.datasync_agent["ip_address"]
  name       = "datasync-agent-${var.datasync_agent["name"]}-${var.env}"

  lifecycle {
    create_before_destroy = false
  }
}

locals {
  storage_account_map = { for account in var.storage_account_list : account.name => account }
}

resource "aws_datasync_location_azure_blob" "this" {
  for_each            = { for name, value in local.storage_account_map : name => value if value.azure_blob != null }
  agent_arns          = [aws_datasync_agent.this.arn]
  authentication_type = "SAS"
  container_url       = each.value.azure_blob.container_url

  sas_configuration {
    token = each.value.azure_blob.token
  }
}

resource "aws_datasync_location_smb" "this" {
  for_each = { for name, value in local.storage_account_map : name => value if value.smb != null }

  agent_arns      = [aws_datasync_agent.this.arn]
  server_hostname = each.value.smb.server_hostname
  subdirectory    = each.value.smb.subdirectory
  user            = each.value.smb.user
  password        = each.value.smb.password
}

resource "aws_datasync_location_s3" "blob" {
  for_each         = local.storage_account_map
  s3_bucket_arn    = aws_s3_bucket.this.arn
  subdirectory     = "/${each.key}/blob"
  s3_storage_class = var.s3_storage_class

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync-s3-access-role.arn
  }
}


resource "aws_datasync_location_s3" "smb" {
  for_each         = local.storage_account_map
  s3_bucket_arn    = aws_s3_bucket.this.arn
  subdirectory     = "/${each.key}/smb"
  s3_storage_class = var.s3_storage_class

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync-s3-access-role.arn
  }
}

resource "aws_datasync_task" "smb_task" {
  for_each                 = { for name, value in local.storage_account_map : name => value if value.smb != null }
  destination_location_arn = aws_datasync_location_s3.smb[each.key].arn
  source_location_arn      = aws_datasync_location_smb.this[each.key].arn
  name                     = "${var.prefix}-${each.key}-smb"

  options {
    bytes_per_second       = -1
    verify_mode            = var.datasync_task_options["verify_mode"]
    posix_permissions      = var.datasync_task_options["posix_permissions"]
    preserve_deleted_files = var.datasync_task_options["preserve_deleted_files"]
    uid                    = var.datasync_task_options["uid"]
    gid                    = var.datasync_task_options["gid"]
    atime                  = var.datasync_task_options["atime"]
    mtime                  = var.datasync_task_options["mtime"]
  }
}


resource "aws_datasync_task" "blob_task" {
  for_each                 = { for name, value in local.storage_account_map : name => value if value.azure_blob != null }
  destination_location_arn = aws_datasync_location_s3.blob[each.key].arn
  source_location_arn      = aws_datasync_location_azure_blob.this[each.key].arn
  name                     = "${var.prefix}-${each.key}-blob"

  options {
    bytes_per_second       = -1
    verify_mode            = var.datasync_task_options["verify_mode"]
    posix_permissions      = var.datasync_task_options["posix_permissions"]
    preserve_deleted_files = var.datasync_task_options["preserve_deleted_files"]
    uid                    = var.datasync_task_options["uid"]
    gid                    = var.datasync_task_options["gid"]
    atime                  = var.datasync_task_options["atime"]
    mtime                  = var.datasync_task_options["mtime"]
  }
}
