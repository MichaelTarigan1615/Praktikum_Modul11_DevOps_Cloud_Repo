resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE" # tfsec:aws-ecr-enforce-immutable-repository

  image_scanning_configuration {
    scan_on_push = true # tfsec:aws-ecr-enable-image-scans
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn # tfsec:aws-ecr-repository-customer-key
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Simpan 10 image terakhir"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
