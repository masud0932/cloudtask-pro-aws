#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting App EC2 bootstrap ==="

# Variables injected by Terraform templatefile()
APP_SECRET_ARN="${app_secret_arn}"
AWS_REGION="${aws_region}"
APP_PORT="${app_port}"
DOCKER_IMAGE="masudrana09/cloudtask-pro:latest"
APP_CONTAINER_NAME="cloudtask-pro"

# Update system
yum update -y

# Install required packages
yum install -y docker aws-cli jq amazon-ssm-agent

# Enable and start services
systemctl enable docker
systemctl start docker

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Docker permissions
usermod -aG docker ec2-user

# Create app directory
mkdir -p /opt/cloudtask
chown -R ec2-user:ec2-user /opt/cloudtask

# Write deploy script used by both bootstrap and Jenkins-triggered SSM deploys
cat > /home/ec2-user/deploy-backend.sh <<EOF
#!/bin/bash
set -euo pipefail

exec > >(tee -a /var/log/deploy-backend.log | logger -t deploy-backend -s 2>/dev/console) 2>&1

APP_SECRET_ARN="$APP_SECRET_ARN"
AWS_REGION="$AWS_REGION"
APP_PORT="$APP_PORT"
DOCKER_IMAGE="masudrana09/cloudtask-pro:latest"
APP_CONTAINER_NAME="cloudtask-pro"

echo "=== Starting backend deployment ==="

# Fetch app secret
SECRET_JSON=\$(aws secretsmanager get-secret-value \
  --secret-id "\$APP_SECRET_ARN" \
  --region "\$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=\$(echo "\$SECRET_JSON" | jq -r '.DB_HOST')
DB_PORT=\$(echo "\$SECRET_JSON" | jq -r '.DB_PORT')
DB_NAME=\$(echo "\$SECRET_JSON" | jq -r '.DB_NAME')
DB_SECRET_ARN=\$(echo "\$SECRET_JSON" | jq -r '.DB_SECRET_ARN')
NODE_ENV=\$(echo "\$SECRET_JSON" | jq -r '.NODE_ENV // "production"')

if [[ -z "\$DB_SECRET_ARN" || "\$DB_SECRET_ARN" == "null" ]]; then
  echo "ERROR: DB_SECRET_ARN missing in app secret"
  exit 1
fi

# Fetch DB credentials from RDS-managed secret
DB_SECRET_JSON=\$(aws secretsmanager get-secret-value \
  --secret-id "\$DB_SECRET_ARN" \
  --region "\$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=\$(echo "\$DB_SECRET_JSON" | jq -r '.username')
DB_PASSWORD=\$(echo "\$DB_SECRET_JSON" | jq -r '.password')

echo "Pulling image: \$DOCKER_IMAGE"
docker pull "\$DOCKER_IMAGE"

echo "Stopping old container if it exists"
docker stop "\$APP_CONTAINER_NAME" || true
docker rm "\$APP_CONTAINER_NAME" || true

echo "Starting new container"
docker run -d \
  --name "\$APP_CONTAINER_NAME" \
  -p "\$APP_PORT:3000" \
  --restart unless-stopped \
  -e PORT=3000 \
  -e NODE_ENV="\$NODE_ENV" \
  -e DB_HOST="\$DB_HOST" \
  -e DB_PORT="\$DB_PORT" \
  -e DB_NAME="\$DB_NAME" \
  -e DB_USER="\$DB_USER" \
  -e DB_PASSWORD="\$DB_PASSWORD" \
  "\$DOCKER_IMAGE"

echo "Waiting for container health"
sleep 10

if ! docker ps --format '{{.Names}}' | grep -q "^\\\$APP_CONTAINER_NAME\\$"; then
  echo "ERROR: Container failed to start"
  docker logs "\$APP_CONTAINER_NAME" || true
  exit 1
fi

echo "=== Backend deployment completed successfully ==="
EOF

chmod +x /home/ec2-user/deploy-backend.sh
chown ec2-user:ec2-user /home/ec2-user/deploy-backend.sh

# Run first deployment during instance bootstrap
/home/ec2-user/deploy-backend.sh

echo "=== App EC2 bootstrap completed ==="