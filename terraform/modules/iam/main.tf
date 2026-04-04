locals {
  secret_arns = concat(var.app_secret_arns, var.extra_secret_arns)
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.tags
}

resource "aws_iam_role" "jenkins" {
  name               = "${var.name_prefix}-jenkins-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = var.tags
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name_prefix}-app-instance-profile"
  role = aws_iam_role.app.name
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.name_prefix}-jenkins-instance-profile"
  role = aws_iam_role.jenkins.name
}

resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "jenkins_cloudwatch" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "app_custom" {
  statement {
    sid       = "ReadSecrets"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = local.secret_arns
  }

  statement {
    sid     = "ReadS3Artifacts"
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = concat(
      var.s3_bucket_arns,
      [for arn in var.s3_bucket_arns : "${arn}/*"]
    )
  }
}

resource "aws_iam_policy" "app_custom" {
  name   = "${var.name_prefix}-app-custom"
  policy = data.aws_iam_policy_document.app_custom.json
}

resource "aws_iam_role_policy_attachment" "app_custom" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app_custom.arn
}

data "aws_iam_policy_document" "jenkins_custom" {
  statement {
    sid = "AllowBasicDeployActions"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "s3:*",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution",
      "secretsmanager:GetSecretValue",
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
      "ssm:GetCommandInvocation",
      "ssm:DescribeInstanceInformation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "jenkins_custom" {
  name   = "${var.name_prefix}-jenkins-custom"
  policy = data.aws_iam_policy_document.jenkins_custom.json
}

resource "aws_iam_role_policy_attachment" "jenkins_custom" {
  role       = aws_iam_role.jenkins.name
  policy_arn = aws_iam_policy.jenkins_custom.arn
}
