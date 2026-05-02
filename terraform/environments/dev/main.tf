provider "aws" {
  region = var.aws_region
}

// Find a recent Amazon Linux 2 AMI
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "vpc" {
  source          = "../../modules/vpc"
  vpc_cidr        = "10.1.0.0/16"
  public_subnets  = ["10.1.0.0/24", "10.1.1.0/24"]
  private_subnets = ["10.1.100.0/24", "10.1.101.0/24"]
  tags            = { environment = "dev" }
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "ocean-across-dev-bucket-unique-replace"
  tags        = { environment = "dev" }
}

module "iam" {
  source      = "../../modules/iam"
  bucket_arn  = module.s3.bucket_arn
  environment = "dev"
}

module "ec2" {
  source        = "../../modules/ec2"
  instance_ami  = data.aws_ami.al2.id
  instance_type = "t3.micro"
  subnet_ids    = module.vpc.public_subnet_ids
  vpc_id        = module.vpc.vpc_id
  ssh_cidr      = "203.0.113.0/32" // replace with admin CIDR
  tags          = { environment = "dev" }
}

module "rds" {
  source                 = "../../modules/rds"
  db_identifier          = "ocean-across-dev-db"
  username               = "oceanadmin"
  password               = var.db_password
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [for _, id in values(module.ec2.security_group_ids) : id]
}

module "monitoring" {
  source           = "../../modules/monitoring"
  environment      = "dev"
  ec2_instance_ids = module.ec2.instance_ids
  rds_identifier   = module.rds.rds_id
  alert_email      = var.alert_email
}
