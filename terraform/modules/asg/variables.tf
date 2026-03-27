variable "name_prefix" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arns" {
  type = list(string)
}

variable "desired_capacity" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "instance_profile_name" {
  type = string
}

variable "app_port" {
  type = number
}

variable "health_check_type" {
  type = string
}

variable "user_data" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
