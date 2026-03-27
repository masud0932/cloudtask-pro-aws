variable "name_prefix" {
  type = string
}

variable "aliases" {
  type = list(string)
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "s3_bucket_regional_domain" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
