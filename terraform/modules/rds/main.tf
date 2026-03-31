resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-postgres-params"
  family = "postgres16"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres-params"
  })
}

resource "aws_db_instance" "this" {
  identifier                      = "${var.name_prefix}-postgres"
  engine                          = "postgres"
  engine_version                  = "16.3"
  instance_class                  = var.db_instance_class
  allocated_storage               = 8
  max_allocated_storage           = 16
  storage_type                    = "gp3"
  storage_encrypted               = true
  db_name                         = var.db_name
  username                        = var.master_username
  manage_master_user_password     = true # Let AWS manage the master user password, it will be stored securely in AWS Secrets Manager
  port                            = var.db_port
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = var.vpc_security_group_ids
  parameter_group_name            = aws_db_parameter_group.this.name
  multi_az                        = var.multi_az
  publicly_accessible             = false
  backup_retention_period         = 7
  deletion_protection             = false
  skip_final_snapshot             = true
  auto_minor_version_upgrade      = true
  performance_insights_enabled    = false
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres"
  })
}
