variable "name_prefix" {
  type = string
}

variable "db_name" {
  type = string
}

variable "master_username" { #db admin username, Important: password is not given here directly.
  type = string
}

variable "db_instance_class" { #e.g. db.t3.microarge, db.t3.xlarge, db.t3.2xlarge
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

variable "multi_az" { #This decides whether RDS should run in Multi-AZ mode, true = high availability standby in another AZ, false = single AZ
  type = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}
