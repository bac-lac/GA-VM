resource "aws_db_subnet_group" "data" {
  name       = "ga-db-subnet-group-${var.ENV}"
  subnet_ids = data.aws_subnets.data.ids
}

resource "aws_db_instance" "ga_mysql" {
  allocated_storage               = 20
  apply_immediately               = true
  auto_minor_version_upgrade      = true
  backup_retention_period         = 35
  copy_tags_to_snapshot           = true
  db_name                         = "ga${var.ENV}"
  db_subnet_group_name            = aws_db_subnet_group.data.name
  enabled_cloudwatch_logs_exports = ["audit", "general", "error", "slowquery"]
  engine                          = "mysql"
  engine_version                  = "8.0"
  identifier                      = "ga-db-${var.ENV}"
  instance_class                  = var.DB_INSTANCE_CLASS
  monitoring_interval             = 5
  monitoring_role_arn             = aws_iam_role.ga_rds_monitoring_role.arn
  parameter_group_name            = "default.mysql8.0"
  password                        = var.ADMIN_DB_PASSWORD
  performance_insights_enabled    = true
  skip_final_snapshot             = true
  storage_encrypted               = true
  username                        = var.ADMIN_DB_USERNAME
  vpc_security_group_ids          = [data.aws_security_group.data.id]
}