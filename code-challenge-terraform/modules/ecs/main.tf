resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${var.env}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json

  inline_policy {
    name   = "allow-registry-access"
    policy = data.aws_iam_policy_document.inline_policy.json

  }

}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions   = ["ecr:*", "iam:CreateServiceLinkedRole", "ssm:GetParameters", "ssm:GetParameterHistory", "ssm:DescribeParameters", "logs:PutLogEvents", "logs:CreateLogGroup", "logs:GetLogEvents", ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

###################################  clusters  ########################################
resource "aws_ecs_cluster" "cluster1" {
  name = "ecs-devops-challenge-${var.env}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  tags = {
    "Environment" = "${var.env}"
  }
}



###################################  services  ########################################
module "frontend_sg" {
  source       = "../security_group"
  vpc_id       = var.vpc_id
  service_name = "${var.env}-frontend"
  rules        = var.frontend_rule

}

module "dev_frontend_webapp" {
  service_name = "${var.env}-frontend"
  source       = "./ecs_service"
  #network
  vpc_id         = var.vpc_id
  subnet_ids     = var.subnet_ids
  container_port = 3000
  #lb and tg configurations
  listener_arn = var.load_balancer["listener_arn"]
  #container and service configurations
  ecs_cluster     = aws_ecs_cluster.cluster1.name
  task_role_arn   = aws_iam_role.ecs_tasks_execution_role.arn
  security_groups = [module.frontend_sg.id]
  alb_arn_suffix  = var.load_balancer["lb_arn_suffix"]
  fqdn            = "frontend-challenge.ctrl.school"
  tg_port         = 3000
  container_definitions = {
    dev-frontend = {
      image       = "${var.repositories["devops-challenge-frontend"]}:frontend"
      command     = []
      environment = []
      secret      = null
      port        = 3000
    }
  }
}


module "backend_sg" {
  source       = "../security_group"
  vpc_id       = var.vpc_id
  service_name = "${var.env}-backend"
  rules        = var.backend_rule

}

module "dev_backend_webapp" {
  service_name = "${var.env}-backend"
  source       = "./ecs_service"
  #network
  vpc_id         = var.vpc_id
  subnet_ids     = var.subnet_ids
  container_port = 8080
  #lb and tg configurations
  listener_arn = var.load_balancer["listener_arn"]
  #container and service configurations
  ecs_cluster     = aws_ecs_cluster.cluster1.name
  task_role_arn   = aws_iam_role.ecs_tasks_execution_role.arn
  security_groups = [module.backend_sg.id]
  alb_arn_suffix  = var.load_balancer["lb_arn_suffix"]
  fqdn            = "backend-challenge.ctrl.school"
  tg_port         = 8080
  container_definitions = {
    dev-backend = {
      image       = "${var.repositories["devops-challenge-backend"]}:backend"
      command     = []
      environment = []
      secret      = null
      port        = 8080
    }
  }
}

output "task_arn" {
  value = aws_iam_role.ecs_tasks_execution_role.arn
}