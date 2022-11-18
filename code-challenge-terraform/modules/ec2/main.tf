data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_network_interface" "jenkins_network_id" {
  subnet_id = var.subnet_ids[0]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = "devops-challenge"

  tags = {
    Name        = "Jenkins"
    Environment = "dev"
  }
}


module "lb_security_group" {
  source       = "../security_group"
  vpc_id       = var.vpc_id
  service_name = "${var.env}-${var.service_cluster}-lb-sg"
  env          = var.env
  description  = var.lb_sg_description
}

resource "aws_lb" "lb" {
  name                       = "${var.env}-${var.service_cluster}-lb"
  internal                   = var.internal
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  security_groups            = [module.lb_security_group.id]
  subnets                    = var.subnet_ids

  enable_deletion_protection = true

  tags = {
    Environment = "${var.env}"
  }
}


resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  tags = {
    "Environment" = "${var.env}"
  }

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "...oops page does not exist"
      status_code  = "404"
    }
  }
}

locals {
  lb_details = {
    lb_dns_name   = "${aws_lb.lb.dns_name}"
    lb_zone_id    = "${aws_lb.lb.zone_id}"
    listener_arn  = "${aws_lb_listener.lb_listener.arn}"
    lb_arn_suffix = "${aws_lb.lb.arn_suffix}"
  }
}