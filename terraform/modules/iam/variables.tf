variable "name_prefix" {
  type = string
}

variable "app_secret_arns" {
  type    = list(string)
  default = []
}

variable "extra_secret_arns" {
  type    = list(string)
  default = []
}

variable "s3_bucket_arns" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
