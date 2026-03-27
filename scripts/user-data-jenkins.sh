#!/bin/bash
set -e

exec > /var/log/user-data.log 2>&1

echo "=== Starting Jenkins EC2 bootstrap ==="

yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Create Jenkins volume
mkdir -p /var/jenkins_home

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

echo "Jenkins started on port 8080"
