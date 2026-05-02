provider "aws" {
  region = var.aws_region
}

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
  vpc_cidr        = "10.2.0.0/16"
  public_subnets  = ["10.2.0.0/24", "10.2.1.0/24"]
  private_subnets = ["10.2.100.0/24", "10.2.101.0/24"]
  tags            = { environment = "prod" }
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "ocean-across-prod-bucket-unique-replace"
  tags        = { environment = "prod" }
}

module "iam" {
  source      = "../../modules/iam"
  bucket_arn  = module.s3.bucket_arn
  environment = "prod"
}

module "ec2" {
  source        = "../../modules/ec2"
  instance_ami  = data.aws_ami.al2.id
  instance_type = "t3.micro"
  subnet_ids    = module.vpc.public_subnet_ids
  vpc_id        = module.vpc.vpc_id
  ssh_cidr      = "198.51.100.0/32" // replace with admin CIDR
  tags          = { environment = "prod" }
}

module "rds" {
  source                 = "../../modules/rds"
  db_identifier          = "ocean-across-prod-db"
  username               = "oceanadmin"
  password               = var.db_password
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [for _, id in values(module.ec2.security_group_ids) : id]
  multi_az               = true
}

module "monitoring" {
  source           = "../../modules/monitoring"
  environment      = "prod"
  ec2_instance_ids = module.ec2.instance_ids
  rds_identifier   = module.rds.rds_id
  alert_email      = var.alert_email
}
