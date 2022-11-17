variable "jenkins_subnet_id" {
  
}

variable "service_cluster" {
  default = "devops-challenge"
}

variable "lb_sg_description" {
  default = "devops-challenge"
}

variable "subnet_ids" {
  
}

variable "vpc_id" {
  
}

variable "env" {
  default = "dev"
}

variable "internal" {
  default = false
}