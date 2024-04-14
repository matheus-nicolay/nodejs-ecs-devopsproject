resource "aws_lb" "nodejs-ecs_lb" {
  name               = "Terraform-ECS-ALB"
  internal           = false
  security_groups    = [aws_security_group.nodejs-ecs_albsg.id]
  load_balancer_type = "application"

  subnets = [aws_subnet.nodejs-ecs_publicsubnet["pub_a"].id, aws_subnet.nodejs-ecs_publicsubnet["pub_b"].id]

  tags = merge(local.common_tags, { Name = "Terraform ECS ALB" })
}

resource "aws_lb_target_group" "nodejs-ecs_lbtg" {
  name        = "ALB-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.nodejs-ecs_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
    path                = "/"
    timeout             = "5"
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_listener" "nodejs-ecs_lbl" {
  load_balancer_arn = aws_lb.nodejs-ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodejs-ecs_lbtg.arn
  }
}

resource "aws_security_group" "nodejs-ecs_albsg" {
  name        = "Terraform-ECS-ALB-SG"
  description = "SG-ALB"
  vpc_id      = aws_vpc.nodejs-ecs_vpc.id


  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name : "Terraform ECS ALB-SG" })
}
