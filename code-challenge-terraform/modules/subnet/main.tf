data "aws_region" "current_region" {}

locals {
  az_letter = ["a", "b", "c", "d", "e", "f", "g"]
  network_flat = flatten([
    for service, network in var.networks : [
      for app, address in network["subnets"] : [
        {
          az        = "${data.aws_region.current_region.name}${local.az_letter[app]}"
          ip        = address
          id        = service
          is_public = network["is_public"]
        }
      ]
    ]
  ])
}

resource "aws_subnet" "subnet" {
  for_each                = { for net_info in local.network_flat : "${net_info.ip}:${net_info.id}" => net_info }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.ip
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.is_public
  tags = {
    Name        = "${each.value.id}-devops-challenge-${var.env}-subnet-${each.value.is_public ? "pub" : "priv"}-${split("-", each.value.az)[2]}"
    Environment = "${var.env}"
  }
}