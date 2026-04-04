#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Starting Jenkins EC2 bootstrap ==="

yum update -y
yum install -y docker git amazon-ssm-agent
systemctl enable docker
systemctl start docker
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Add ec2-user to docker group
usermod -aG docker ec2-user

mkdir -p /var/jenkins_home
mkdir -p /opt/jenkins-docker
cd /opt/jenkins-docker

cat > Dockerfile <<'EOF'
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && \
    apt-get install -y docker.io git curl && \
    rm -rf /var/lib/apt/lists/*
USER jenkins
EOF

docker build -t my-jenkins-docker .

docker rm -f jenkins || true

docker run -d \
  --name jenkins \
  --restart unless-stopped \
  --user root \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins-docker

echo "=== Jenkins started on port 8080 ==="



