
variable "env" {
  default = "dev"
}

variable "ecr_repo" {
  type = map(any)
  default = {
    reposit1 = {
      image_tag_mutability     = true
      image_scan_on_push       = true
      encryption_type          = "AES256"
      attach_repository_policy = false
    }
    repo2 = {
      image_tag_mutability     = true
      image_scan_on_push       = true
      encryption_type          = "KMS"
      attach_repository_policy = true
    }
  }
}







