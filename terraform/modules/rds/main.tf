resource "aws_db_subnet_group" "this" {
  name       = "ocean-across-db-subnet-group-${var.db_identifier}"
  subnet_ids = var.subnet_ids
  tags = { Name = "ocean-across-db-subnet-group" }
}

resource "aws_db_instance" "this" {
  identifier              = var.db_identifier
  engine                  = var.engine
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = "ocean_across_db"
  username                = var.username
  password                = var.password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_encrypted       = true
  multi_az                = var.multi_az
  backup_retention_period = 7
  tags = { Name = "ocean-across-rds" }
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "id" {
  value = aws_db_instance.this.id
}
