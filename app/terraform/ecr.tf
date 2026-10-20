resource "aws_ecr_repository" "api" {
  name                 = "cloud-lab-api"
  image_tag_mutability = "MUTABLE"
  force_delete       = true
}
