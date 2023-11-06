
variable "datasync_agent" {
  type        = map(string)
  description = "A Map of datasync agent variables"
}

variable "storage_account_list" {
  type = list(object({
    name = string
    smb = optional(object({
      server_hostname = string
      subdirectory    = string
      user            = string
      password        = string
    }))
    azure_blob = optional(object({
      container_url = string
      token         = string
    }))
  }))
  default = [
    {
      name       = "dummy"
      smb        = null
      azure_blob = null
    }
  ]
}

variable "cmk_s3_alias" {
  type    = string
  default = "evoila-cmk-s3"
}

variable "kms_cmk_s3_description" {
  type    = string
  default = "CMK to encrypt S3 Data"
}

variable "datasync_task_options" {
  type        = map(string)
  description = "A map of datasync_task options block"
  default = {
    verify_mode            = "POINT_IN_TIME_CONSISTENT"
    posix_permissions      = "NONE"
    preserve_deleted_files = "REMOVE"
    uid                    = "NONE"
    gid                    = "NONE"
    atime                  = "NONE"
    mtime                  = "NONE"
    bytes_per_second       = "-1"
  }
}

variable "env" {
  type    = string
  default = "test"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "bucket_name" {
  type = string
}

variable "project_tag" {
  type    = string
  default = "evoila-tf-datasync-project"
}

variable "prefix" {
  type    = string
  default = "evoila-tf-datasync"
}

variable "s3_storage_class" {
  type    = string
  default = "GLACIER_INSTANT_RETRIEVAL"
}
