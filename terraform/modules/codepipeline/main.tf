# S3 Bucket untuk Artifact Store CodePipeline (Enkripsi KMS + Versioning + Block Public Access)
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-${var.environment}-pipeline-artifacts"
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SNS Topic Terenkripsi KMS untuk Notifikasi Manual Approval
resource "aws_sns_topic" "approval" {
  name              = "${var.project_name}-${var.environment}-approval-topic"
  kms_master_key_id = var.kms_key_arn
}

# IAM Role untuk CodeBuild & CodePipeline
resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-${var.environment}-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
    }]
  })
}

resource "aws_codebuild_project" "this" {
  name          = "${var.project_name}-${var.environment}-build"
  description   = "Menyiapkan imagedefinitions.json dan validasi Terraform untuk deployment ECS"
  service_role  = aws_iam_role.codebuild.arn
  encryption_key = var.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECR_REPOSITORY_NAME"
      value = var.ecr_repository_name
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = "app-container"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-${var.environment}-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
    }]
  })
}

resource "aws_codepipeline" "this" {
  name     = "${var.project_name}-${var.environment}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  # STAGE 1: Source (GitHub via CodeStar Connection + ECR Image)
  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.github_repo_id
        BranchName       = "main"
      }
    }
  }

  # STAGE 2: Build (CodeBuild menghasilkan imagedefinitions.json dari image yang di-build GitHub Actions)
  stage {
    name = "Build"

    action {
      name             = "Build_Artifact_Spec"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    }
  }

  # STAGE 3: Manual Approval Gate (Wajib Lab 3 - Tech Lead Approval)
  stage {
    name = "Manual_Approval"

    action {
      name     = "Approve_Production_Deploy"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.approval.arn
        CustomData      = "Mohon review hasil CI GitHub Actions & Terraform Plan sebelum menyetujui rilis ke ECS Fargate Production."
      }
    }
  }

  # STAGE 4: Deploy ke Amazon ECS Fargate Production
  stage {
    name = "Deploy_to_ECS"

    action {
      name            = "Deploy_ECS_Fargate"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
