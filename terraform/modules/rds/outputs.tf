output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "db_endpoint" {
  value = split(":", aws_db_instance.this.endpoint)[0]
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "master_secret_arn" {
  value = aws_db_instance.this.master_user_secret[0].secret_arn
}
