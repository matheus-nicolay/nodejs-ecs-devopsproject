resource "aws_vpc" "nodejs-ecs_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, { Name : "Terraform-ECS VPC" })
}

resource "aws_internet_gateway" "nodejs-ecs_igw" {
  vpc_id = aws_vpc.nodejs-ecs_vpc.id
  tags   = merge(local.common_tags, { Name : "Terraform-ECS IGW" })
}

resource "aws_eip" "nodejs-ecs_nateip" {
  domain = "vpc"
}

resource "aws_subnet" "nodejs-ecs_publicsubnet" {
  for_each = {
    "pub_a" : ["192.168.1.0/24", "${var.aws_region}a", "Public A"]
    "pub_b" : ["192.168.2.0/24", "${var.aws_region}b", "Public B"]
  }

  vpc_id            = aws_vpc.nodejs-ecs_vpc.id
  cidr_block        = each.value[0]
  availability_zone = each.value[1]

  tags = merge(local.common_tags, { Name = each.value[2] })
}

resource "aws_subnet" "nodejs-ecs_privatesubnet" {
  for_each = {
    "priv_a" : ["192.168.3.0/24", "${var.aws_region}a", "Private A"]
    "priv_b" : ["192.168.4.0/24", "${var.aws_region}b", "Private B"]
  }

  vpc_id            = aws_vpc.nodejs-ecs_vpc.id
  cidr_block        = each.value[0]
  availability_zone = each.value[1]

  tags = merge(local.common_tags, { Name = each.value[2] })
}

resource "aws_nat_gateway" "nodejs-ecs_ngw" {
    allocation_id           = aws_eip.nodejs-ecs_nateip.id
    subnet_id               = aws_subnet.nodejs-ecs_publicsubnet[0].id
    depends_on              = [ aws_internet_gateway.nodejs-ecs_igw ]
}

resource "aws_route_table" "nodejs-ecs_public" {
  vpc_id = aws_vpc.nodejs-ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nodejs-ecs_igw.id
  }

  tags = merge(local.common_tags, { Name = "Terraform-ECS Public" })
}


resource "aws_route_table_association" "nodejs-ecs_tapublic" {
  for_each = local.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.nodejs-ecs_public.id
}

resource "aws_route_table" "nodejs-ecs_private" {
  vpc_id = aws_vpc.nodejs-ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nodejs-ecs_ngw.id
  }

  tags = merge(local.common_tags, { Name = "Terraform-ECS Public" })
}

resource "aws_route_table_association" "nodejs-ecs_taprivate" {
  for_each = local.subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.nodejs-ecs_private.id
}
