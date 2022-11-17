variable "rules" {
  type = map(any)
  default = {
    "Allow http traffic from internet" = {
      from_port          = "80"
      to_port            = "80"
      protocol           = "tcp"
      allowed_cidr_block = "0.0.0.0/0"
    }
    "Allow traffic from internet" = {
      from_port          = "443"
      to_port            = "443"
      protocol           = "tcp"
      allowed_cidr_block = "0.0.0.0/0"
    }
  }
}

variable "env" {
  default = "dev"
}

variable "service_name" {
}

variable "vpc_id" {

}

# variable "sg_name" {

# }

variable "description" {
  default = "managed with terraform"
}