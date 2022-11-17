resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name        = "devops-challenge-${var.env}-vpc"
    Environment = "${var.env}"
  }
}

module "public_subnets" {
  source   = "../subnet"
  vpc_id   = aws_vpc.vpc.id
  env      = var.env
  networks = var.public_subnets
}

module "private_subnets" {
  source   = "../subnet"
  vpc_id   = aws_vpc.vpc.id
  env      = var.env
  networks = var.private_subnets
}

resource "aws_eip" "ngw_eip" {
  vpc = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "public-devops-challenge-${var.env}-internetgw-pub"
    Environment = "${var.env}"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw_eip.id
  subnet_id     = module.public_subnets.subnet_id[0]

  tags = {
    Name        = "public-devops-challenge-${var.env}-natgw-pub"
    Environment = "${var.env}"
  }
  depends_on = [aws_internet_gateway.igw]
}

module "public_route_table" {
  source     = "../route_table"
  env        = var.env
  service    = "public"
  subnet_ids = module.public_subnets.subnet_id
  gateways   = ["${aws_internet_gateway.igw.id}:internet_gw"]
  vpc_id     = aws_vpc.vpc.id
  routes     = var.public_routes
  is_public  = true
}

module "private_route_table" {
  source     = "../route_table"
  env        = var.env
  service    = "private"
  subnet_ids = module.private_subnets.subnet_id
  gateways   = ["${aws_nat_gateway.ngw.id}:nat_gw"]
  vpc_id     = aws_vpc.vpc.id
  routes     = var.private_routes
  is_public  = false
}