resource "aws_ecr_repository" "api" {
  name                 = "cloud-lab-api"
  image_tag_mutability = "MUTABLE"
  force_delete       = true
}

output "ecr_repository_url" {
  value = aws_ecr_repository.api.repository_url
}