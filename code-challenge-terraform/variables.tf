variable "vpc_cidr_block" {
  default = "10.100.0.0/16"
}

variable "public_subnets" {
  type = map(any)
  default = {
    rds = {
      subnets   = ["10.100.12.0/22", "10.100.16.0/22"]
      is_public = true
    }
  }
}

variable "priv_subnets" {
  type = map(any)
  default = {
    ecs = {
      subnets   = ["10.100.0.0/22", "10.100.4.0/22"]
      is_public = false
    }
  }
}

variable "public_routes" {
  type = map(any)
  default = {
    route1 = {
      "route" = ["0.0.0.0/0", "internet_gw"]
    }
  }
}

variable "private_routes" {
  type = map(any)
  default = {
    route1 = {
      "route" = ["0.0.0.0/0", "nat_gw"]
    }
  }
}

variable "ecr_repo" {
  type = map(any)
  default = {
    devops-challenge-backend = {
      image_tag_mutability     = true
      image_scan_on_push       = true
      encryption_type          = "AES256"
      attach_repository_policy = true
    }
    devops-challenge-frontend = {
      image_tag_mutability     = true
      image_scan_on_push       = true
      encryption_type          = "AES256"
      attach_repository_policy = true
    }
  }
}