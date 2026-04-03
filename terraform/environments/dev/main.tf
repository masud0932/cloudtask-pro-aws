locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                     = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  single_nat_gateway       = true
  tags                     = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix           = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  app_port              = var.app_port
  db_port               = var.db_port
  jenkins_allowed_cidrs = var.jenkins_allowed_cidrs
  tags                  = local.common_tags
}

module "sns" {
  source = "../../modules/sns"

  name_prefix       = local.name_prefix
  email_subscribers = var.alert_email_addresses
  tags              = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix            = local.name_prefix
  db_name                = var.db_name
  master_username        = var.db_master_username
  db_instance_class      = var.db_instance_class
  subnet_ids             = module.vpc.private_db_subnet_ids
  vpc_security_group_ids = [module.security.db_sg_id]
  db_port                = var.db_port
  multi_az               = true
  tags                   = local.common_tags
}

module "secrets" {
  source = "../../modules/secrets"

  name_prefix   = local.name_prefix
  app_port      = var.app_port
  db_host       = module.rds.db_endpoint
  db_port       = var.db_port
  db_name       = var.db_name
  db_secret_arn = module.rds.master_secret_arn
  tags          = local.common_tags
}

module "s3" {
  source = "../../modules/s3"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  name_prefix       = local.name_prefix
  app_secret_arns   = [module.secrets.app_secret_arn, module.rds.master_secret_arn]
  extra_secret_arns = []
  s3_bucket_arns    = [module.s3.artifacts_bucket_arn, module.s3.frontend_bucket_arn]
  tags              = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name_prefix        = local.name_prefix
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security.alb_sg_id]
  vpc_id             = module.vpc.vpc_id
  app_port           = var.app_port
  health_check_path  = var.health_check_path
  tags               = local.common_tags
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  name_prefix               = local.name_prefix
  aliases                   = []
  s3_bucket_name            = module.s3.frontend_bucket_id
  s3_bucket_arn             = module.s3.frontend_bucket_arn
  s3_bucket_regional_domain = module.s3.frontend_bucket_regional_domain_name
  tags                      = local.common_tags
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  name_prefix             = local.name_prefix
  sns_topic_arn           = module.sns.topic_arn
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  db_instance_id          = module.rds.db_instance_id
  tags                    = local.common_tags
}

module "asg" {
  source = "../../modules/asg"

  name_prefix           = local.name_prefix
  ami_id                = data.aws_ami.amazon_linux.id
  instance_type         = var.app_instance_type
  subnet_ids            = module.vpc.private_app_subnet_ids
  security_group_ids    = [module.security.app_sg_id]
  target_group_arns     = [module.alb.target_group_arn]
  desired_capacity      = var.app_desired_capacity
  min_size              = var.app_min_size
  max_size              = var.app_max_size
  instance_profile_name = module.iam.app_instance_profile_name
  app_port              = var.app_port
  health_check_type     = "ELB"

  user_data = templatefile("${path.module}/../../../scripts/user-data-app.sh", {
    app_secret_arn = module.secrets.app_secret_arn
    aws_region     = var.aws_region
    app_port       = var.app_port
  })

  tags = local.common_tags
}

module "jenkins" {
  source = "../../modules/jenkins"

  name_prefix           = local.name_prefix
  ami_id                = data.aws_ami.amazon_linux.id
  instance_type         = var.jenkins_instance_type
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_ids    = [module.security.jenkins_sg_id]
  instance_profile_name = module.iam.jenkins_instance_profile_name
  user_data             = templatefile("${path.module}/../../../scripts/user-data-jenkins.sh", {})
  key_name              = var.key_name
  tags                  = local.common_tags
}
