variable "instance_ami" {
  description = "AMI to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "List of subnet ids to place instances into"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC id where instances will be placed"
  type        = string
}

variable "key_name" {
  description = "Optional SSH key name"
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH"
  type        = string
  default     = "10.0.0.0/8"
}

variable "tags" {
  type    = map(string)
  default = {}
}
