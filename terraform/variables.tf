variable "aws_region" {
  description = "AWS Region untuk deployment infrastruktur"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Nama proyek untuk penamaan resource dan Cost Tagging"
  type        = string
  default     = "fasilkomti-devops"
}

variable "environment" {
  description = "Nama environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Nama kelompok atau pemilik resource untuk FinOps Tagging"
  type        = string
  default     = "Kelompok-Praktikum-USU"
}

variable "vpc_cidr" {
  description = "CIDR block untuk VPC utama"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Daftar 2 Availability Zones sesuai syarat Lab 2"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR block untuk Public Subnets (2 AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR block untuk Private Subnets ECS Fargate (2 AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "container_port" {
  description = "Port tempat container aplikasi berjalan"
  type        = number
  default     = 8080
}

variable "github_repo_id" {
  description = "Nama repository GitHub dalam format owner/repo"
  type        = string
  default     = "mahasiswa-usu/devops-cloud-modul11"
}

variable "codestar_connection_arn" {
  description = "ARN AWS CodeStar Connection untuk GitHub"
  type        = string
  default     = "arn:aws:codestar-connections:ap-southeast-1:123456789012:connection/example-connection-id"
}
