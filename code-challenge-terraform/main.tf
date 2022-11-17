module "network" {
  source = "./modules/network"
  private_subnets = var.priv_subnets
  public_subnets  = var.public_subnets
  vpc_cidr_block = var.vpc_cidr_block
  public_routes = var.public_routes
  private_routes = var.private_routes
}

module "ec2" {
  source = "./modules/ec2"
  jenkins_subnet_id = module.network.public_subnet_ids[0]
  subnet_ids =  module.network.public_subnet_ids
  vpc_id = module.network.id
}

module "ecr" {
  source = "./modules/ecr"
  ecr_repo = var.ecr_repo
}

module "ecs" {
  source = "./modules/ecs"
  subnet_ids = module.network.private_subnet_ids
  load_balancer = module.ec2.lb_details
  vpc_id = module.network.id
  repositories = module.ecr.repositry_url
}

output "url" {
  value = module.ecs.task_arn
}