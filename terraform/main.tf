terraform {
  required_version = ">= 0.11.11" // older might be ok, this is just the version I used
}

provider "aws" {
  version = "~> 1.56"
  region  = "${var.region}"
}

provider "null" {
  version = "~> 2.0"
}

provider "random" {
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}

locals {
  service_discovery_namespace = "${var.stack_name}.local"
}

resource "aws_service_discovery_private_dns_namespace" "local" {
  name = "${local.service_discovery_namespace}"
  vpc  = "${module.vpc.vpc_id}"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  name = "${var.stack_name}"

  cidr = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_nat_gateway   = true

  // We arent really doing multi az yet but "aws_db_subnet_group.database" in the vpc module needs at least 2 AZs
  azs = ["ap-southeast-2a", "ap-southeast-2b"]

  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.111.0/24", "10.0.112.0/24"]

  tags = {
    Stack = "${var.stack_name}"
  }
}

module "kong" {
  source = "./modules/kong"

  db_security_group_ids          = ["${aws_security_group.postgres.id}"]
  db_subnet_ids                  = ["${module.vpc.database_subnets}"]
  ecs_cluster_id                 = "${module.ecs.this_ecs_cluster_id}"
  kong_image                     = "${var.kong_image}"
  load_balancer_target_group_arn = "${module.kong_lb.target_group_arns[0]}"
  log_group                      = "${var.cloudwatch_log_group}"
  log_region                     = "${var.region}"
  name                           = "${var.stack_name}-kong"
  service_discovery_namespace    = "${local.service_discovery_namespace}"
  vpc_id                         = "${module.vpc.vpc_id}"

  tags = {
    Stack = "${var.stack_name}"
  }
}

module "kong_lb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  load_balancer_name = "${var.stack_name}-kong"

  logging_enabled = false
  security_groups = ["${aws_security_group.public_load_balancer.id}"]
  subnets         = ["${module.vpc.public_subnets}"]
  vpc_id          = "${module.vpc.vpc_id}"

  http_tcp_listeners_count = "1"

  http_tcp_listeners = [{
    port     = 80
    protocol = "HTTP"
  }]

  target_groups_count = "1"

  target_groups = [{
    name = "${var.stack_name}-kong"

    backend_port     = "1"    // this value is never used, ECS supplies its own port number
    backend_protocol = "HTTP"

    health_check_healthy_threshold = 2
    health_check_matcher           = "404"
    // health check to kong itself rather than something upstream of kong
    health_check_path              = "/health-check-from-ecs-should-404"
  }]

  tags = {
    Stack = "${var.stack_name}"
  }
}
