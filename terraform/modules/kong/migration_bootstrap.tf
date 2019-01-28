locals {
  "kong_migration_bootstrap" = [
    {
      name = "migration"
      image = "${var.kong_image}"
      command = ["kong", "migrations", "bootstrap"]
      environment = [
        { name = "KONG_DATABASE", value = "postgres" },
        { name = "KONG_LOG_LEVEL", value = "debug" },
        { name = "KONG_PG_DATABASE", value = "${module.db.this_db_instance_name}" },
        { name = "KONG_PG_HOST", value = "${module.db.this_db_instance_address}" },
        { name = "KONG_PG_PASSWORD", value = "${module.db.this_db_instance_password}" },
        { name = "KONG_PG_PORT", value = "string:${module.db.this_db_instance_port}" },
        { name = "KONG_PG_USER", value = "${module.db.this_db_instance_username}" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options {
          awslogs-group = "${var.log_group}"
          awslogs-region = "${var.log_region}"
          awslogs-stream-prefix = "task-kong-migration-bootstrap"
        }
      }
    }
  ]
}

resource "aws_ecs_task_definition" "migration_bootstrap" {
  // replace() is a workaround for https://github.com/hashicorp/terraform/issues/17033
  container_definitions = "${replace(replace(jsonencode(local.kong_migration_bootstrap), "/\"([0-9]+)\"/", "$1"), "string:", "")}"

  family = "${var.name}-migration-bootstrap"

  memory = 50 // MB (the value is a first guess)

  network_mode = "bridge"

  tags = "${var.tags}"
}
