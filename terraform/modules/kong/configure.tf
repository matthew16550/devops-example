locals {
  "kong_configure_container_definitions" = [
    {
      name = "python"
      image = "python:3.7.2-alpine3.8"
      command = ["/bin/sh", "-c", <<-EOF
        export ADMIN_URL="http://$ADMIN_PORT_8001_TCP_ADDR:$ADMIN_PORT_8001_TCP_PORT"
        echo "$SCRIPT" > /root/script
        chmod a+x /root/script
        /root/script
        EOF
      ]
      environment = [
        // there will be a limit on env var size so the script cant get too big (maybe 32k ?)
        { name = "SCRIPT" value = "${file("${path.module}/files/configure.py")}" },
        { name = "SERVICE_DISCOVERY_NAMESPACE" value = "${var.service_discovery_namespace}" },
      ]
      links = ["admin"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "${var.log_group}"
          awslogs-region = "${var.log_region}"
          awslogs-stream-prefix = "task-kong-configure"
        }
      }
    },
    {
      name = "admin"
      image = "${var.kong_image}"
      environment = [
        { name = "KONG_ADMIN_ACCESS_LOG", value = "/dev/stdout" },
        { name = "KONG_ADMIN_ERROR_LOG", value = "/dev/stderr" },
        { name = "KONG_ADMIN_LISTEN",  value = "0.0.0.0:8001" },
        { name = "KONG_DATABASE", value = "postgres" },
        { name = "KONG_LOG_LEVEL", value = "debug" },
        { name = "KONG_PG_DATABASE", value = "${module.db.this_db_instance_name}" },
        { name = "KONG_PG_HOST", value = "${module.db.this_db_instance_address}" },
        { name = "KONG_PG_PASSWORD", value = "${module.db.this_db_instance_password}" },
        { name = "KONG_PG_PORT", value = "string:${module.db.this_db_instance_port}" },
        { name = "KONG_PG_USER", value = "${module.db.this_db_instance_username}" },
        { name = "KONG_PROXY_LISTEN", value = "off" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options {
          awslogs-datetime-format = "%Y/%m/%d %H:%M:%S"
          awslogs-group = "${var.log_group}"
          awslogs-region = "${var.log_region}"
          awslogs-stream-prefix = "task-kong-configure"
        }
      }
      portMappings = [
        { containerPort = 8001 }
      ]
      ulimits = [
        { name = "nofile", softLimit = "4096", hardLimit = "4096" }
      ]
    }
  ]
}

resource "aws_ecs_task_definition" "configure" {
  // replace() is a workaround for https://github.com/hashicorp/terraform/issues/17033
  container_definitions = "${replace(replace(jsonencode(local.kong_configure_container_definitions), "/\"([0-9]+)\"/", "$1"), "string:", "")}"

  family = "${var.name}-configure"

  memory = 50 // MB (the value is a first guess)

  network_mode = "bridge"

  tags = "${var.tags}"
}
