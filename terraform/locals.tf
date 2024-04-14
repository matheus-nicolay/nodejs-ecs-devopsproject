locals {

  private_subnets = {
    priv_a = ["192.168.3.0/24", "${var.aws_region}a", "Private A"]
    priv_b = ["192.168.4.0/24", "${var.aws_region}b", "Private B"]
  }

  subnet_ids         = { for k, v in aws_subnet.nodejs-ecs_publicsubnet : v.tags.Name => v.id }
  private_subnet_ids = { for k, v in aws_subnet.nodejs-ecs_privatesubnet : v.tags.Name => v.id }

  common_tags = {
    Project   = "ECS Fargate"
    CreatedAt = "2024-04-13"
    Owner     = "Matheus Nicolay"
    Service   = "ECS Fargate"
  }
}