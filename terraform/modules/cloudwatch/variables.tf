variable "name_prefix" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
