output "vpc_id" {
  description = "ID dari VPC yang dibuat"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL Amazon ECR Repository"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Nama Amazon ECS Fargate Cluster"
  value       = module.ecs_fargate.cluster_name
}

output "alb_dns_name" {
  description = "DNS Name dari Application Load Balancer"
  value       = module.ecs_fargate.alb_dns_name
}

output "codepipeline_name" {
  description = "Nama AWS CodePipeline untuk Continuous Delivery"
  value       = module.codepipeline.pipeline_name
}
