// These are described in SETTINGS.sh

variable "allow_ssh_from_cidr" {
  type = "string"
}

variable "ecs_ami_name" {
  type = "string"
}

variable "kong_image" {
  type = "string"
}

variable "ssh_key_pair_name" {
  type = "string"
}

variable "cloudwatch_log_group" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "stack_name" {
  type = "string"
}
