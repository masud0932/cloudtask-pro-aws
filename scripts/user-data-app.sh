#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

echo "=== Starting App EC2 bootstrap ==="

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Install AWS CLI v2 (if not present)
yum install -y aws-cli

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Variables from Terraform
APP_SECRET_ARN="${app_secret_arn}" # ARN of the secret containing app config (DB host, port, name, and DB secret ARN) 
AWS_REGION="${aws_region}"
APP_PORT="${app_port}"

echo "Fetching app secrets from Secrets Manager..."

# Get secret JSON
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$APP_SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

echo "$SECRET_JSON" > /home/ec2-user/app_secrets.json

# Extract variables
DB_HOST=$(echo $SECRET_JSON | jq -r '.DB_HOST')
DB_PORT=$(echo $SECRET_JSON | jq -r '.DB_PORT')
DB_NAME=$(echo $SECRET_JSON | jq -r '.DB_NAME')
DB_SECRET_ARN=$(echo $SECRET_JSON | jq -r '.DB_SECRET_ARN')
NODE_ENV=$(echo $SECRET_JSON | jq -r '.NODE_ENV')

# Fetch DB credentials (managed by RDS)
DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo $DB_SECRET_JSON | jq -r '.username')
DB_PASSWORD=$(echo $DB_SECRET_JSON | jq -r '.password')

echo "Running backend container..."

# Pull your backend image (replace later with ECR)
docker pull node:22-alpine

# Run container
docker run -d \
  --name cloudtask-backend \
  -p $APP_PORT:3000 \
  -e PORT=3000 \
  -e NODE_ENV=$NODE_ENV \
  -e DB_HOST=$DB_HOST \
  -e DB_PORT=$DB_PORT \
  -e DB_NAME=$DB_NAME \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  node:22-alpine \
  sh -c "npm install -g serve && serve -s /usr/src/app"

echo "=== App bootstrap completed ==="
