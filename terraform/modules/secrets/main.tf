resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "app" {
  name = "${var.name_prefix}/app-config"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id

  secret_string = jsonencode({
    PORT          = tostring(var.app_port)
    NODE_ENV      = "production"
    DB_HOST       = var.db_host
    DB_PORT       = tostring(var.db_port)
    DB_NAME       = var.db_name
    DB_SECRET_ARN = var.db_secret_arn
    JWT_SECRET    = random_password.jwt_secret.result
  })
}
