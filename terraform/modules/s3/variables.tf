variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_kms" {
  type    = bool
  default = true
}
