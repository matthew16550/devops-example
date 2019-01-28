resource "aws_security_group" "ssh_from_bastion" {
  name   = "${var.stack_name}-ssh-from-bastion"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    cidr_blocks = ["${module.vpc.public_subnets_cidr_blocks}"] # TODO restrict to bastion SG as the source
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
  }

  tags = {
    Stack = "${var.stack_name}"
  }
}

resource "aws_security_group" "public_load_balancer" {
  name   = "${var.stack_name}-public-load-balancer"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["${module.vpc.private_subnets_cidr_blocks}"]
    protocol    = "tcp"
    from_port   = 32768
    to_port     = 60999
  }

  tags = {
    Stack = "${var.stack_name}"
  }
}

resource "aws_security_group" "ecs_instances" {
  name   = "${var.stack_name}-ecs-instances"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    security_groups = ["${aws_security_group.public_load_balancer.id}"]
    protocol        = "tcp"
    from_port       = 32768                                             // containers will listen in this range
    to_port         = 60999
  }

  // For DockerHub and ECS service. The later might be avoided via a VPC Endpoint to ECS.
  // TODO add network acl to block traffic to others inside VPC (ie this rule should not be allowing egress to VPC addresses)
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  egress {
    cidr_blocks = ["${module.vpc.database_subnets_cidr_blocks}"]
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
  }

  tags = {
    Stack = "${var.stack_name}"
  }
}

resource "aws_security_group" "postgres" {
  name   = "${var.stack_name}-postgres"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    security_groups = ["${aws_security_group.ecs_instances.id}"]
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Stack = "${var.stack_name}"
  }
}
