output "aws_console_ecs" {
  value = "https://${var.region}.console.aws.amazon.com/ecs/home?region=${var.region}#/clusters/${var.stack_name}/services"
}

output "aws_console_cloudwatch_logs" {
  value = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#logStream:group=${var.cloudwatch_log_group}"
}

output "aws_console_cloudwatch_logs_db" {
  value = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#logStream:group=/aws/rds/instance/${var.stack_name}-kong/postgresql"
}

output "bastion_address" {
  value = "${module.bastion.public_ip}"
}

output "hello_url" {
  value = "http://${module.kong_lb.dns_name}/hello"
}

output "kong_admin_url" {
  value = "http://${module.kong_lb.dns_name}/admin-api"
}

output "kong_url" {
  value = "http://${module.kong_lb.dns_name}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
