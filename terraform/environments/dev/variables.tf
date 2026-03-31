variable "project_name" {
  type    = string
  default = "cloudtask-pro"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type = list(string)
  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_app_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "private_db_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_name" {
  type    = string
  default = "cloudtask"
}

variable "db_master_username" {
  type    = string
  default = "cloudtask_admin"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "jenkins_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "app_desired_capacity" {
  type    = number
  default = 2
}

variable "app_min_size" {
  type    = number
  default = 2
}

variable "app_max_size" {
  type    = number
  default = 4
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "jenkins_allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "alert_email_addresses" {
  type    = list(string)
  default = []
}
