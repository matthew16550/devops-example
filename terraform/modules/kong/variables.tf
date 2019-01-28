variable "db_security_group_ids" {
  type = "list"
}

variable "db_subnet_ids" {
  type = "list"
}

variable "ecs_cluster_id" {
  type = "string"
}

variable "kong_image" {
  type = "string"
}

variable "load_balancer_target_group_arn" {
  type = "string"
}

variable "log_group" {
  type = "string"
}

variable "log_region" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "service_discovery_namespace" {
  type = "string"
}

variable "tags" {
  type = "map"
}

variable "vpc_id" {
  type = "string"
}
