module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "1.0.0"
  name    = "${var.stack_name}"
}

module "ecs_instances_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.9.1"
  name    = "${var.stack_name}-ecs-instances"

  # Launch config
  iam_instance_profile = "${module.ecs_instance_profile.this_iam_instance_profile_id}"
  image_id             = "${data.aws_ami.ecs_optimized.id}"
  instance_type        = "t2.micro"
  key_name             = "${var.ssh_key_pair_name}"

  security_groups = [
    "${aws_security_group.ecs_instances.id}",
    "${aws_security_group.ssh_from_bastion.id}",
  ]

  user_data = <<-EOF
    #! /usr/bin/env bash
    echo ECS_CLUSTER=${module.ecs.this_ecs_cluster_id} > /etc/ecs/ecs.config
  EOF

  # Autoscaling group
  vpc_zone_identifier       = ["${module.vpc.private_subnets}"]
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags_as_map = {
    Stack = "${var.stack_name}"
  }
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["${var.ecs_ami_name}"]
  }
}

module "ecs_instance_profile" {
  source  = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  version = "1.0.0"
  name    = "${var.stack_name}"
}
