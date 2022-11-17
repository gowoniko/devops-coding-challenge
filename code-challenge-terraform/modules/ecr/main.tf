
resource "aws_ecr_repository" "ecr" {
  for_each = var.ecr_repo

  name                 = each.key
  image_tag_mutability = each.value.image_tag_mutability ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = each.value.image_scan_on_push
  }
  encryption_configuration {
    encryption_type = each.value.encryption_type == "KMS" ? "KMS" : "AES256"
  }

  tags = {
    Name        = "${each.key}-ules-${var.env}"
    Environment = "${var.env}"
  }
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  for_each = { for k, v in var.ecr_repo : k => v if v.attach_repository_policy }

  repository = aws_ecr_repository.ecr[each.key].name
  policy     = <<EOF
{
    "Statement": [
        {
            "Sid": "ecr policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

