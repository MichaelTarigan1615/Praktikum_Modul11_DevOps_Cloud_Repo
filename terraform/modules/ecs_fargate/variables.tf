variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "ecr_repository_url" { type = string }
variable "container_port" { type = number }
variable "kms_key_arn" { type = string }
