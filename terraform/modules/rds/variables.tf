variable "name_prefix" {
  type = string
}

variable "db_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "db_port" {
  type = number
}

variable "multi_az" {
  type = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}
