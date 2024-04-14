provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "nmatheus-tfstate-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }
}

resource "aws_ecs_cluster" "nodejs-ecs_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "nodejs-ecs_td" {
  family                   = var.cluster_task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.cluster_task}",
      "image": "${var.image_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": ${var.memory},
      "cpu": ${var.cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_service" "nodejs-ecs_service" {
  name                = var.cluster_service
  cluster             = aws_ecs_cluster.nodejs-ecs_cluster.id
  task_definition     = aws_ecs_task_definition.nodejs-ecs_td.arn
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count       = var.desired_capacity

  load_balancer {
    target_group_arn = aws_lb_target_group.nodejs-ecs_lbtg.arn
    container_name   = aws_ecs_task_definition.nodejs-ecs_td.family
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = [aws_subnet.nodejs-ecs_privatesubnet["priv_a"].id, aws_subnet.nodejs-ecs_privatesubnet["priv_b"].id]
    security_groups  = [aws_security_group.nodejs-ecs_ecssg.id]
    assign_public_ip = true
  }

}

resource "aws_security_group" "nodejs-ecs_ecssg" {
  name        = "Terraform-ECS TASK SG"
  description = "Terraform-ECS SG"
  vpc_id      = aws_vpc.nodejs-ecs_vpc.id

  #Allow inbound traffic from ALB
  ingress {
    protocol        = "tcp"
    from_port       = var.container_port
    to_port         = var.container_port
    security_groups = [aws_security_group.nodejs-ecs_albsg.id]
  }

  #Allow Outbound
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}