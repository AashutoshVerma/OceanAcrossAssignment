// EC2 module: creates three service instances with isolated security groups
locals {
  services = [
    { name = "companies-service", port = 80 },
    { name = "bureaus-service",   port = 80 },
    { name = "employees-service", port = 80 },
  ]
}

resource "aws_security_group" "svc" {
  for_each = { for svc in local.services : svc.name => svc }
  name        = "ocean-${each.key}-sg-${var.tags.environment}"
  vpc_id      = var.vpc_id
  description = "Security group for ${each.key}"

  ingress {
    description = "SSH from admin network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP to service (open: consider ALB in production)"
    from_port   = each.value.port
    to_port     = each.value.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "ocean-${each.key}" }, var.tags)
}

resource "aws_instance" "svc" {
  for_each = { for idx, svc in local.services : svc.name => svc }
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, lookup({"companies-service"=0,"bureaus-service"=1,"employees-service"=0}, each.key, 0))
  vpc_security_group_ids = [aws_security_group.svc[each.key].id]
  key_name               = var.key_name == "" ? null : var.key_name

  tags = merge({ Name = each.key }, var.tags)
}

output "ec2_instance_ids" {
  value = { for k, i in aws_instance.svc : k => i.id }
}

output "ec2_security_group_ids" {
  value = { for k, s in aws_security_group.svc : k => s.id }
}
