variable "bucket_arn" {
  description = "ARN of S3 bucket to restrict access to"
  type        = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "tags" {
  type    = map(string)
  default = {}
}
