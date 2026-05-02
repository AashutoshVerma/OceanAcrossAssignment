variable "aws_region" {
  default = "eu-west-2"
}

variable "db_password" {
  description = "DB admin password (sensitive - inject via TF var or use Secrets Manager)"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive critical alerts via SNS (optional)"
  type        = string
  default     = ""
}
