module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "1.22.0"

  identifier           = "${var.name}"
  engine               = "postgres"
  engine_version       = "9.6.11"
  family               = "postgres9.6" // for aws_db_parameter_group
  major_engine_version = "9.6"         // for db_option_group

  allocated_storage   = 5             // gibibytes - currently just a guess
  deletion_protection = false
  instance_class      = "db.t2.micro"
  port                = "5432"

  subnet_ids             = ["${var.db_subnet_ids}"]
  vpc_security_group_ids = ["${var.db_security_group_ids}"]

  parameters = [
    {
      name  = "log_statement"
      value = "all"           // TODO change this before production
    },
  ]

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  backup_retention_period = 0
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  name     = "kong"
  username = "kong"
  password = "password"

  tags = "${var.tags}"
}
