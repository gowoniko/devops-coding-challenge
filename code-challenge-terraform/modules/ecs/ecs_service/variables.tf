variable "container_definitions" {
  
}

variable "service_name" {
  
}

variable "task_role_arn" {
  
}

variable "compute_info" {
  default = [256,512]
}

variable "vpc_id" {

}

variable "tg_port" {
  default = 80
}

variable "container_port_protocol" {
  default = "tcp"
}

variable "container_port" {
  description = "The container port to expose"

}

variable "subnet_ids" {
  description = "list of subnet ids to associtate the service with"
}

variable "health_check_path" {
  default = "/"
}

variable "tg_protocol" {
  default = "HTTP"
}

variable "tg_target_type" {
  default = "ip"
}

variable "tg_unhealthy_threshold" {
  default = 5
}

variable "tg_healthy_threshold" {
  default = 2
}

variable "tg_timeout" {
  default = 5
}

variable "tg_interval" {
  default = 30
}

variable "health_check_success_codes" {
  default = "200" 
}

variable "desired_count" {
  default = 1
}

variable "security_groups" {
  
}

variable "ecs_cluster" {
  
}

variable "alb_arn_suffix" {
  
}

variable "listener_arn" {
  
}

variable "expose_service" {
  default = true
}

