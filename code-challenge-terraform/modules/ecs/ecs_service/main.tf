data "aws_region" "current_region" {}



locals {
  container_info = flatten([
    for service_name, container_details in var.container_definitions : [
      {
        env1          = jsonencode(container_details["environment"])
        container_def = <<TASK_DEFINITION

  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${service_name}",
        "awslogs-region": "${data.aws_region.current_region.name}",
        "awslogs-create-group": "true",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
              {
          "hostPort": ${container_details["port"]},
          "protocol": "tcp",
          "containerPort": ${container_details["port"]}
        }
    ],
    "command": [ ${join(", ", [for command in container_details["command"] : format("%q", command)])} ],
    "environment": ${jsonencode(container_details["environment"])},
    "secrets": ${jsonencode(container_details["secret"])},
    "mountPoints": [],
    "volumesFrom": [],
    "image": "${container_details["image"]}",
    "name": "${service_name}"
  }
TASK_DEFINITION
      }
    ]
  ])

  containers = "[${join(",", [for k, v in local.container_info : "${v.container_def}"])}]"

}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.service_name
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.task_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.compute_info[0]
  memory                   = var.compute_info[1]
  container_definitions    = local.containers



  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}


resource "aws_lb_target_group" "target_group" {
  name        = var.service_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  target_type = var.tg_target_type
  vpc_id      = var.vpc_id
  health_check {
    path                = var.health_check_path
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
    timeout             = var.tg_timeout
    interval            = var.tg_interval
    matcher             = var.health_check_success_codes
  }
}

#get latest task definition revision
data "aws_ecs_task_definition" "task_definition_revision" {
  task_definition = aws_ecs_task_definition.task_definition.family
}



resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.ecs_cluster
  task_definition = "${aws_ecs_task_definition.task_definition.family}:${max(aws_ecs_task_definition.task_definition.revision, data.aws_ecs_task_definition.task_definition_revision.revision)}"
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

}

##########################      Expose service      #############################
resource "aws_lb_listener_rule" "account_rule" {
  count        = var.expose_service ? 1 : 0
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    host_header {
      values = ["${var.fqdn}"]
    }
  }
}