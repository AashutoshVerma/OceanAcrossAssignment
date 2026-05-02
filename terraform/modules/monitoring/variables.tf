variable "environment" {
  type = string
}

variable "ec2_instance_ids" {
  type    = map(string)
  default = {}
}

variable "rds_identifier" {
  type    = string
  default = ""
}

variable "enable_rds_monitoring" {
  type    = bool
  default = true
}

variable "alert_email" {
  type    = string
  default = ""
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "ec2_cpu_threshold" {
  type    = number
  default = 80
}

variable "ec2_period" {
  type    = number
  default = 300
}

variable "ec2_eval_periods" {
  type    = number
  default = 2
}

variable "rds_conn_threshold" {
  type    = number
  default = 100
}

variable "rds_period" {
  type    = number
  default = 300
}

variable "rds_eval_periods" {
  type    = number
  default = 2
}
