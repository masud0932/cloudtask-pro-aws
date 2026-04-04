#!/bin/bash
set -xeuo pipefail
LOCK_FILE="/tmp/cloudtask-backend-deploy.lock"

exec 200>"$LOCK_FILE"
flock -n 200 || {
  echo "Another deployment is already running. Exiting."
  exit 1
}

exec > >(tee -a /var/log/deploy-backend.log | logger -t deploy-backend -s 2>/dev/console) 2>&1

APP_SECRET_ARN="${1:-}"
AWS_REGION="${2:-eu-central-1}"
APP_PORT="${3:-3000}"
DOCKER_IMAGE="${4:-masudrana09/cloudtask-pro:latest}"
APP_CONTAINER_NAME="${5:-cloudtask-pro}"

if [[ -z "$APP_SECRET_ARN" ]]; then
  echo "Usage: $0 <app_secret_arn> [aws_region] [app_port] [docker_image] [container_name]"
  exit 1
fi

echo "=== Starting backend deployment ==="

# Fetch app config secret
SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$APP_SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.DB_HOST')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.DB_PORT')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.DB_NAME')
DB_SECRET_ARN=$(echo "$SECRET_JSON" | jq -r '.DB_SECRET_ARN')
NODE_ENV=$(echo "$SECRET_JSON" | jq -r '.NODE_ENV // "production"')

if [[ -z "$DB_SECRET_ARN" || "$DB_SECRET_ARN" == "null" ]]; then
  echo "ERROR: DB_SECRET_ARN missing in app secret"
  exit 1
fi

# Fetch DB credentials
DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$DB_SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.password')

echo "Pulling image: $DOCKER_IMAGE"
docker pull "$DOCKER_IMAGE"

echo "Stopping old container if present"
docker stop "$APP_CONTAINER_NAME" || true
docker rm "$APP_CONTAINER_NAME" || true

echo "Starting container"
docker run -d \
  --name "$APP_CONTAINER_NAME" \
  -p "$APP_PORT:3000" \
  --restart unless-stopped \
  -e PORT=3000 \
  -e NODE_ENV="$NODE_ENV" \
  -e DB_HOST="$DB_HOST" \
  -e DB_PORT="$DB_PORT" \
  -e DB_NAME="$DB_NAME" \
  -e DB_USER="$DB_USER" \
  -e DB_PASSWORD="$DB_PASSWORD" \
  "$DOCKER_IMAGE"

echo "Waiting for application health"
for i in $(seq 1 18); do
  if docker ps --format '{{.Names}}' | grep -q "^${APP_CONTAINER_NAME}$"; then
    if curl -fsS "http://localhost:${APP_PORT}/health" >/dev/null; then
      echo "Application health check passed"
      echo "=== Backend deployment completed successfully ==="
      exit 0
    fi
  else
    echo "Container not running yet on attempt $i"
  fi

  sleep 5
done

echo "ERROR: Application failed to become healthy"
docker ps -a
docker logs "$APP_CONTAINER_NAME" || true
exit 1

echo "Checking application health endpoint"
for i in $(seq 1 12); do
  if curl -fsS "http://localhost:${APP_PORT}/health" >/dev/null; then
    echo "Application health check passed"
    echo "=== Backend deployment completed successfully ==="
    exit 0
  fi
  sleep 5
done

echo "ERROR: Application health check failed"
docker logs "$APP_CONTAINER_NAME" || true
exit 1

echo "=== Backend deployment completed successfully ==="