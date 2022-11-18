variable "env" {
  default = "dev"
}

variable "subnet_ids" {
  description = "list of subnet ids to associtate the service with"
}

variable "load_balancer" {

}

variable "vpc_id" {

}

variable "repositories" {

}

variable "frontend_rule" {
  type = map(any)
  default = {
    "Allow http traffic from internet" = {
      from_port          = "3000"
      to_port            = "3000"
      protocol           = "tcp"
      allowed_cidr_block = "0.0.0.0/0"
    }
  }
}

variable "backend_rule" {
  type = map(any)
  default = {
    "Allow http traffic from internet" = {
      from_port          = "8080"
      to_port            = "8080"
      protocol           = "tcp"
      allowed_cidr_block = "0.0.0.0/0"
    }
  }
}