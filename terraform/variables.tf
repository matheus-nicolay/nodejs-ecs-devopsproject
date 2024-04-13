variable "aws_access_key" {
  type        = string
  description = "use env aws keys"
}

variable "aws_secret_key" {
  type        = string
  description = "use env aws keys"
}

variable "tfstate_bucket_name" {
  type        = string
  description = "name of s3 bucket for tfstate"
  default = "nmatheus-tfstate-bucket"
}


variable "aws_region" {
  default = "us-east-1"
}

variable "desired_capacity" {
  description = "desired number of running nodes"
  default     = 3
}

variable "container_port" {
  default = "3000"
}

variable "image_url" {
  default = "514866477147.dkr.ecr.us-east-1.amazonaws.com/nodejs-app:latest"
}

variable "memory" {
  default = "512"
}

variable "cpu" {
  default = "256"
}

variable "cluster_name" {
  default = "nodejs-ecs-cluster"
}

variable "cluster_task" {
  default = "nodejs-ecs-task"
}
variable "cluster_service" {
  default = "nodejs-ecs-service"
}

variable "container_image" {
  default = "nodejs-app"
}