variable "name_prefix" {
  type = string
}

variable "email_subscribers" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
