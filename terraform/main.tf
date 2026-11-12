# ============================================================================
# 0. KMS Key Terpusat untuk Enkripsi S3, ECR, dan CloudWatch Logs (Lolos tfsec)
# ============================================================================
resource "aws_kms_key" "main" {
  description             = "KMS Key untuk enkripsi ECR, S3 Artifact, dan CloudWatch Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.project_name}-${var.environment}-key"
  target_key_id = aws_kms_key.main.key_id
}

# ============================================================================
# 1. Modul VPC (2 Availability Zones + Public/Private Subnets + VPC Flow Logs)
# ============================================================================
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  kms_key_arn          = aws_kms_key.main.arn
}

# ============================================================================
# 2. Modul Amazon ECR (Immutable Image Tag + Scan on Push + KMS Encryption)
# ============================================================================
module "ecr" {
  source = "./modules/ecr"

  repository_name = "${var.project_name}-app"
  kms_key_arn     = aws_kms_key.main.arn
}

# ============================================================================
# 3. Modul ECS Fargate Cluster, Service, Task Definition, & ALB
# ============================================================================
module "ecs_fargate" {
  source = "./modules/ecs_fargate"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  ecr_repository_url = module.ecr.repository_url
  container_port     = var.container_port
  kms_key_arn        = aws_kms_key.main.arn
}

# ============================================================================
# 4. Modul Lab 3: AWS CodePipeline (Source ECR/GitHub -> CodeBuild -> Manual Approval -> Deploy ECS)
# ============================================================================
module "codepipeline" {
  source = "./modules/codepipeline"

  project_name            = var.project_name
  environment             = var.environment
  ecr_repository_name     = module.ecr.repository_name
  ecs_cluster_name        = module.ecs_fargate.cluster_name
  ecs_service_name        = module.ecs_fargate.service_name
  github_repo_id          = var.github_repo_id
  codestar_connection_arn = var.codestar_connection_arn
  kms_key_arn             = aws_kms_key.main.arn
}
