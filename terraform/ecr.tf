resource "aws_ecr_repository" "repo" {
  name                 = var.project
  image_tag_mutability = "MUTABLE"
  tags = { Name = var.project }
}
