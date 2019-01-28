// This file runs a simple Hello World web server on ECS, Kong will use SRV records to find it.

resource "aws_service_discovery_service" "hello" {
  name = "hello"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.local.id}"

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }

  health_check_custom_config {
    failure_threshold = 3
  }
}

resource "aws_ecs_service" "hello" {
  name            = "hello"
  cluster         = "${module.ecs.this_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.hello.arn}"
  desired_count   = 0

  service_registries {
    registry_arn   = "${aws_service_discovery_service.hello.arn}"
    container_name = "hello"
    container_port = "80"
  }

  lifecycle {
    ignore_changes = [
      "desired_count",
    ]
  }
}

resource "aws_ecs_task_definition" "hello" {
  container_definitions = <<-EOF
[
  {
    "name": "hello",
    "image": "nginxdemos/hello:0.2",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${var.cloudwatch_log_group}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "task-hello"
      }
    },
    "portMappings": [{ "containerPort": 80 }]
  }
]
  EOF

  family = "${var.stack_name}-hello"

  memory = 10 // MB (the value is a first guess)

  network_mode = "bridge"

  tags = {
    Stack = "${var.stack_name}"
  }
}
