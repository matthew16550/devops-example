// This file runs a Kong proxy service on ECS and connects it to the provided load_balancer_target_group_arn

// Note the admin port is not exposed via portMappings because ECS Service Load Balancing only manages one port
// per service.  Instead we use kong to proxy to its own admin port via the '/admin-api' path (see configure.tf).
// (Service Load Balancing seems the simplest way to allow dynamic container ports)

locals {
  "kong_proxy_container_definitions" = [
    {
      name = "kong"
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
        { name = "KONG_PROXY_ACCESS_LOG", value = "/dev/stdout" },
        { name = "KONG_PROXY_ERROR_LOG", value = "/dev/stderr" },
        { name = "KONG_PROXY_LISTEN", value = "0.0.0.0:8000" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options {
          awslogs-datetime-format = "%Y/%m/%d %H:%M:%S"
          awslogs-group = "${var.log_group}"
          awslogs-region = "${var.log_region}"
          awslogs-stream-prefix = "task-kong-proxy"
        }
      }
      portMappings = [
        { containerPort = 8000 }
      ]
      ulimits = [
        { name = "nofile", softLimit = "4096", hardLimit = "4096" }
      ]
    }
  ]
}

resource "aws_ecs_task_definition" "proxy" {
  // replace() is a workaround for https://github.com/hashicorp/terraform/issues/17033
  container_definitions = "${replace(replace(jsonencode(local.kong_proxy_container_definitions), "/\"([0-9]+)\"/", "$1"), "string:", "")}"

  family = "${var.name}-proxy"

  memory = 50 // MB (the value is a first guess)

  network_mode = "bridge"

  tags = "${var.tags}"
}

resource "aws_ecs_service" "proxy" {
  name            = "kong-proxy"
  cluster         = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.proxy.arn}"
  desired_count   = 0

  load_balancer {
    target_group_arn = "${var.load_balancer_target_group_arn}"
    container_name   = "kong"
    container_port   = 8000
  }

  lifecycle {
    ignore_changes = [
      "desired_count"
    ]
  }
}
