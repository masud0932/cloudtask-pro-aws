variable "name_prefix" {
  type = string
}

variable "app_port" {
  type = number
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_name" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
