1. Project Title
### CloudTask Pro - Production-Style 3-Tier Cloud Application with Terraform, Jenkins, Docker, Auto Scaling, ALB, CloudFront, and RDS

CloudTask Pro is a **production-style AWS cloud project** that demonstrates how to design, provision, and deploy a modern web application using **Infrastructure as Code**, **CI/CD**, **containerized backend services**, and **high-availability cloud architecture**.

---

## Project Overview

CloudTask Pro is a production-style task management platform deployed on AWS using modern DevOps and cloud engineering practices.

The project was built to simulate how a real-world web application would be deployed in an enterprise environment using Infrastructure as Code, CI/CD, containerization, load balancing, auto scaling, secure secret management, and cloud-native services.

CloudTask Pro allows users to:

view task dashboard metrics
create and manage tasks
organize work by projects
interact with a backend API connected to PostgreSQL

The application uses a React frontend, a Node.js backend, and a PostgreSQL database hosted on Amazon RDS.

The platform includes:

•	React + Vite frontend
•	Node.js + Express backend API
•	PostgreSQL database hosted on Amazon RDS
•	Dockerized backend deployment
•	S3 and CloudFront for frontend hosting
•	Application Load Balancer and Auto Scaling Group for backend availability
•	Jenkins-based CI/CD pipeline
•	Terraform-based infrastructure provisioning
•	AWS Secrets Manager for secure secret handling
•	AWS Systems Manager for deployment automation
This project reflects a real production workflow where infrastructure, application deployment, security, and automation are managed together in a scalable and reproducible way.

---
## Project Structure
The repository is organized to separate application code, infrastructure code, deployment scripts, and CI/CD configuration. This keeps the project easier to maintain and reflects a production-style layout.
cloudtask-pro-aws/
├── app/
│   ├── frontend/                 # React + Vite frontend application
│   │   ├── public/               # Static public assets
│   │   ├── src/                  # Frontend source code
│   │   │   ├── components/       # Reusable UI components
│   │   │   ├── assets/           # Images, icons, styles
│   │   │   └── App.jsx           # Main frontend entry component
│   │   ├── .env.production       # Production frontend environment variables
│   │   ├── package.json
│   │   ├── vite.config.js
│   │   └── Dockerfile
│   │
│   └── backend/                  # Node.js + Express backend API
│       ├── src/
│       │   ├── db/               # DB connection and initialization logic
│       │   │   ├── pool.js
│       │   │   └── init.js
│       │   ├── routes/           # API route handlers
│       │   │   ├── health.js
│       │   │   ├── tasks.js
│       │   │   ├── projects.js
│       │   │   ├── dashboard.js
│       │   │   ├── auth.js
│       │   │   └── errorHandler.js
│       │   └── server.js         # Main backend entry point
│       ├── package.json
│       ├── Dockerfile
│       └── .env                  # Local backend environment variables
│
├── terraform/
│   ├── environments/
│   │   └── dev/                  # Environment-specific Terraform configuration
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars
│   │
│   └── modules/                  # Reusable Terraform modules
│       ├── vpc/
│       ├── security-groups/
│       ├── alb/
│       ├── ec2/
│       ├── asg/
│       ├── rds/
│       ├── s3/
│       ├── cloudfront/
│       ├── iam/
│       ├── secrets/
│       ├── cloudwatch/
│       └── jenkins/
│
├── scripts/
│   ├── deploy-backend.sh         # Backend deployment script executed through SSM
│   ├── user-data-app.sh          # EC2 bootstrap script for backend/app instances
│   └── user-data-jenkins.sh      # EC2 bootstrap script for Jenkins server
│
├── Jenkinsfile                   # Jenkins CI/CD pipeline definition
├── README.md                     # Project documentation
└── .gitignore

----
## Infrastructure Overview
The infrastructure is designed to simulate a production-style AWS environment using Terraform, Docker, Jenkins, and multiple AWS services.
The application follows a multi-tier architecture where frontend, backend, database, CI/CD, and networking components are separated into dedicated layers.
High-Level Flow
1.	Users access the frontend through CloudFront
2.	CloudFront serves static frontend files stored in S3
3.	Frontend API requests are sent to the Application Load Balancer
4.	The ALB forwards traffic to backend EC2 instances running inside an Auto Scaling Group
5.	Backend containers connect to PostgreSQL running on Amazon RDS
6.	Secrets such as database credentials and JWT keys are retrieved from AWS Secrets Manager
7.	Jenkins manages automated deployments using AWS Systems Manager (SSM)

Networking Layer
The project uses a dedicated VPC with multiple subnets across two Availability Zones for better availability and fault tolerance.
The networking design includes:
•	2 public subnets
•	2 private subnets
•	Internet Gateway
•	NAT Gateway
•	Route Tables
•	Security Groups
Public subnets are used for:
•	Application Load Balancer
•	Jenkins server
•	NAT Gateway
Private subnets are used for:
•	Backend application EC2 instances
•	RDS PostgreSQL database
This setup ensures that backend instances and the database are not directly exposed to the internet.

Frontend Layer
The frontend is built using React and Vite.
The production frontend files are stored in an S3 bucket and distributed globally through CloudFront.
Frontend requests follow this path:
User → CloudFront → S3 Bucket
Benefits of this approach include:
•	low-cost static hosting
•	faster global content delivery
•	caching through CloudFront
•	separation of frontend and backend layers

Backend Layer
The backend is built with Node.js and Express and runs inside Docker containers on EC2 instances.
Backend instances are part of an Auto Scaling Group so that failed instances can be replaced automatically and additional instances can be added when traffic increases.
Traffic flow for backend requests:
User → ALB → EC2 Auto Scaling Group → Docker Container
The backend instances are deployed inside private subnets and only receive traffic through the Application Load Balancer.

Database Layer
The application uses PostgreSQL hosted on Amazon RDS.
The database is deployed inside private subnets and is not publicly accessible.
Database access is restricted using Security Groups so that only backend EC2 instances can connect to it.
Example database connection flow:
Backend Container → RDS PostgreSQL

Security Layer
Several AWS services are used to improve security:
•	IAM roles for EC2, Jenkins, and deployment permissions
•	Security Groups to restrict traffic between components
•	AWS Secrets Manager for storing database credentials and JWT secrets
•	Private subnets for backend and database resources
•	SSM for secure remote command execution without opening SSH access
•	Encrypted EBS volumes for EC2 instances
•	Encrypted RDS storage
Secrets are not hardcoded in the application. Instead, the backend retrieves sensitive values dynamically from AWS Secrets Manager during deployment.

CI/CD Layer
A dedicated Jenkins server is used for CI/CD.
Jenkins is hosted on EC2 and runs inside Docker.
The CI/CD pipeline performs:
•	frontend build and deployment to S3
•	backend Docker image build
•	Docker Hub push
•	SSM-based backend deployment
•	health check validation
Deployment flow:
GitHub → Jenkins → Docker Hub → SSM → EC2 Backend

Infrastructure as Code
All AWS resources are provisioned using Terraform.
The Terraform code is organized into reusable modules such as:
•	VPC
•	Security Groups
•	ALB
•	EC2
•	Auto Scaling Group
•	RDS
•	S3
•	CloudFront
•	IAM
•	Secrets Manager
•	Jenkins
This makes the infrastructure reproducible, easier to maintain, and easier to extend in the future.
________________________________________
Availability and Fault Tolerance
The project includes several production-style availability features:
•	Multi-AZ subnet design
•	Auto Scaling Group for backend instances
•	Load balancing with ALB
•	Health checks for backend containers
•	CloudFront caching for frontend content
•	Automatic EC2 replacement on failure
These features improve system reliability and reduce downtime.
-----------
Monitoring and Alerting

Basic monitoring is implemented using Application Load Balancer health checks, Docker logs, backend logs, and Jenkins deployment logs.

The backend exposes a health endpoint:

/health

This endpoint is used by the Application Load Balancer to determine whether backend instances are healthy.

Deployment logs are stored on EC2 instances, for example:

/var/log/deploy-backend.log
/var/log/user-data.log

Docker container logs are also useful during troubleshooting:

docker logs cloudtask-pro

---

## Tech Stack

### Frontend

* React
* Vite
* JavaScript
* Axios
* CSS

### Backend

* Node.js
* Express.js
* PostgreSQL
* pg library
* dotenv

### Infrastructure

* Amazon VPC
* Public and Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* Application Load Balancer
* Auto Scaling Group
* Amazon EC2
* Amazon RDS PostgreSQL
* Amazon S3
* Amazon CloudFront
* AWS Secrets Manager
* AWS Systems Manager
* Amazon CloudWatch
* IAM Roles and Policies

### DevOps & CI/CD

* Jenkins
* GitHub Webhooks
* Docker
* Docker Hub
* Terraform
* Bash Scripting

### Monitoring & Logging

* Amazon CloudWatch Metrics
* Amazon CloudWatch Logs
* Application Health Checks
* ALB Target Group Health Checks

### Security

* IAM Least Privilege Access
* Secrets Management with AWS Secrets Manager
* Private Subnet for Backend and Database
* Security Group Based Traffic Control
* Encrypted RDS Storage
* HTTPS Support through CloudFront


---

## Terraform module structure

This project uses a **modular Terraform design** for maintainability and reusability.

### Modules

* `vpc` – networking foundation
* `security` – security groups
* `alb` – application load balancer and target group
* `asg` – backend compute layer
* `rds` – PostgreSQL database
* `s3` – frontend and artifact buckets
* `cloudfront` – frontend CDN distribution
* `iam` – roles and instance profiles
* `secrets` – application secrets
* `cloudwatch` – alarms and logs
* `sns` – notifications
* `jenkins` – Jenkins server provisioning

### Environments

* `terraform/environments/dev`
* `terraform/environments/prod`

This makes the repository look closer to how real cloud teams organize Terraform code.

```
## CI/CD Pipeline
The project uses a fully automated CI/CD pipeline built with Jenkins, GitHub, Docker, and AWS services.
Whenever new code is pushed to the GitHub repository, a GitHub webhook automatically triggers Jenkins to start the deployment pipeline.
Pipeline Flow
1.	Developer pushes code to the GitHub repository
2.	GitHub webhook automatically triggers Jenkins
3.	Jenkins pulls the latest changes
4.	Frontend is built using React/Vite
5.	Frontend build artifacts are uploaded to S3
6.	Backend Docker image is built
7.	Backend Docker image is pushed to Docker Hub
8.	Jenkins identifies the running backend EC2 instance
9.	Jenkins uploads the latest deployment script
10.	Jenkins uses AWS Systems Manager (SSM) to deploy the new backend version
11.	Application Load Balancer health checks verify successful deployment


________________________________________
Pipeline Stages
1. GitHub Webhook Trigger
Whenever code is pushed to the repository, GitHub automatically sends a webhook request to Jenkins.
This removes the need to manually start builds from the Jenkins dashboard.

2. Checkout Source Code
Jenkins clones the latest version of the repository from GitHub.
git clone <git repo>

3. Frontend Build
The frontend is built using npm and Vite.
cd app/frontend
npm ci
npm run build
This generates the production-ready dist/ folder.

4. Frontend Deployment to S3
The generated frontend files are uploaded to the S3 bucket.
aws s3 sync dist/ s3://cloudtask-pro-dev-frontend-bucket --delete --region eu-central-1
The --delete flag ensures old files are removed from S3 so that outdated frontend assets are not served.

5. Backend Docker Image Build
The backend application is packaged into a Docker image.
cd app/backend
docker build -t cloudtask-pro-backend .

6. Docker Image Push to Docker Hub
After building the backend image, Jenkins tags and pushes it to Docker Hub.
docker tag cloudtask-pro-backend masudrana09/cloudtask-pro:latest
docker push masudrana09/cloudtask-pro:latest

7. Discover Running Backend EC2 Instance
Jenkins dynamically finds the running backend EC2 instance in the Auto Scaling Group.
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=cloudtask-pro-dev-app" \
            "Name=instance-state-name,Values=running" \
  --region eu-central-1
This avoids hardcoding EC2 instance IDs and supports dynamic infrastructure changes.

8. Upload Latest Deployment Script
To avoid using outdated deployment scripts already stored on EC2, Jenkins uploads the latest version during every deployment.
Example actions include:
scp scripts/deploy-backend.sh ec2-user@APP_SERVER_IP:/home/ec2-user/deploy-backend.sh
chmod +x /home/ec2-user/deploy-backend.sh
This ensures the latest deployment logic is always used.

9. Backend Deployment Using SSM
Jenkins uses AWS Systems Manager Run Command to deploy the latest backend container without requiring direct SSH access.
Example deployment actions include:
docker pull masudrana09/cloudtask-pro:latest
docker stop cloudtask-pro || true
docker rm cloudtask-pro || true
docker run -d \
  --name cloudtask-pro \
  -p 3000:3000 \
  --restart unless-stopped \
  -e NODE_ENV=production \
  -e RUN_DB_INIT=true \
  -e APP_SECRET_ARN=$APP_SECRET_ARN \
  masudrana09/cloudtask-pro:latest
This ensures the backend container is recreated with the latest image and environment variables.

10. Health Check Validation
After deployment, Jenkins waits for the backend application to become healthy.
curl http://<app-ec2-ip>:3000/health
Expected response:
{
  "status": "ok",
  "service": "cloudtask-pro-backend",
  "database": "connected"
}
The Application Load Balancer also performs periodic health checks against:
/health

---

## Security practices implemented

This project includes multiple production-oriented security considerations:

* backend EC2 instances are deployed in **private subnets**
* database is deployed in **private DB subnets**
* backend traffic is allowed only from the **ALB security group**
* database traffic is allowed only from the **app security group**
* secrets are stored in **AWS Secrets Manager**
* operational access is designed around **SSM**, reducing the need for direct server access
* IAM roles are used for controlled AWS access
* infrastructure is defined as code to improve consistency and auditability

---

## Monitoring and observability

The project includes:

* CloudWatch log groups
* ALB-related monitoring
* unhealthy target monitoring
* RDS monitoring
* SNS notifications for alarms

This helps demonstrate operational awareness, not just deployment ability.

---

## Repository structure

```text
cloudtask-pro-aws/
├── terraform/
│   ├── bootstrap/
│   ├── modules/
│   └── environments/
├── app/
│   ├── backend/
│   └── frontend/
├── jenkins/
├── scripts/
├── diagrams/
├── docs/
└── README.md
```

---

## Local development

### Backend

```bash
cd app/backend
cp .env.example .env
npm install
npm run dev
```

### Frontend

```bash
cd app/frontend
cp .env.example .env
npm install
npm run dev
```

### Local PostgreSQL with Docker

```bash
docker run --name cloudtask-postgres \
  -e POSTGRES_DB=cloudtask \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  -d postgres:16
```

---

## Terraform usage

### Go to the environment folder

```bash
cd terraform/environments/dev
```

### Initialize Terraform

```bash
terraform init
```

### Validate configuration

```bash
terraform validate
```

### Preview changes

```bash
terraform plan
```

### Apply infrastructure

```bash
terraform apply
```

---

## Project highlights for recruiters

This project demonstrates practical skills in:

* AWS architecture design
* Terraform-based infrastructure provisioning
* Jenkins-driven CI/CD
* Docker-based backend delivery
* scalable and secure application deployment
* cloud networking design
* secrets management
* monitoring and alerting
* production-style system thinking

---

## Resume-ready summary

You can describe this project on your CV like this:

**CloudTask Pro on AWS** — Designed and implemented a production-style 3-tier AWS application using Terraform, Jenkins, Docker, EC2 Auto Scaling, Application Load Balancer, CloudFront, S3, and RDS PostgreSQL, with secure networking, secrets management, monitoring, and automated deployment workflows.

Or in shorter form:

Designed a production-style AWS cloud application with Terraform, Jenkins CI/CD, Dockerized backend services, Auto Scaling, ALB, S3/CloudFront frontend delivery, RDS PostgreSQL, Secrets Manager, and CloudWatch monitoring.

---

## Business value of this project

This project reflects how cloud infrastructure can be built to support:

* scalability
* repeatable deployment
* lower manual operations effort
* improved security posture
* better maintainability
* faster software delivery

It is intended as a portfolio project that demonstrates readiness for roles in:

* DevOps Engineering
* Cloud Engineering
* Platform Engineering
* DevSecOps
* Site Reliability Engineering

---

## Current status

* Backend application developed and tested locally
* Frontend application developed and tested locally
* Terraform project structure created
* Modular infrastructure design in progress
* Jenkins-based CI/CD design prepared
* AWS deployment workflow being integrated

---

## Planned improvements

Future enhancements may include:

* Amazon ECR for backend image storage
* blue/green deployment strategy
* AWS WAF integration
* Redis caching layer
* enhanced monitoring dashboards
* production-grade backup and recovery policies
* container orchestration migration path (ECS or EKS)

---

## Screenshots

Add screenshots here after deployment:

```md
### Application UI
![Frontend Screenshot](docs/screenshots/frontend.png)

### Jenkins Pipeline
![Jenkins Screenshot](docs/screenshots/jenkins.png)

### AWS Architecture
![AWS Screenshot](docs/screenshots/aws.png)
```

---

## Key learning outcomes

This project helped strengthen hands-on skills in:

* Terraform module design
* AWS networking architecture
* secure infrastructure patterns
* CI/CD pipeline design
* Docker-based application deployment
* cloud service integration
* cloud operations mindset

---

## Author

**Md Masud Rana**
DevOps / Cloud / DevSecOps focused engineer with hands-on interest in production-style AWS architecture, CI/CD automation, and secure cloud delivery.

---

## License

This project is for portfolio, learning, and demonstration purposes.

````
## Challenges Faced and Solutions Implemented
1. Jenkins Container Missing Node.js and npm
Challenge:
The Jenkins server was running inside Docker, but the base Jenkins image did not include Node.js or npm. As a result, frontend build stages failed with:
npm: not found
Solution:
A custom Jenkins Docker image was created with Node.js and npm preinstalled. This allowed Jenkins to build the React/Vite frontend directly inside the Jenkins container.

2. Frontend Build Artifacts Missing
Challenge:
The frontend deployment stage failed because the dist/ folder did not exist.
Root Cause:
The frontend build process had failed earlier due to missing npm.
Solution:
After fixing Node.js/npm inside Jenkins, the frontend stage was updated to use:
npm ci
npm run build
This ensured the dist/ folder was generated before uploading to S3.

3. Missing IAM Permissions for Jenkins
Challenge:
Jenkins could not use AWS Systems Manager (SSM) commands to deploy the backend. Errors such as the following occurred:
AccessDeniedException
Solution:
Additional IAM permissions were attached to the Jenkins EC2 role, including:
•	ssm:SendCommand
•	ssm:ListCommandInvocations
•	ssm:DescribeInstanceInformation
This allowed Jenkins to send deployment commands and monitor execution status.

4. Backend Deployment Script Timeout
Challenge:
Backend deployments frequently timed out because Jenkins could not properly determine whether the SSM command succeeded or failed.
Solution:
The deployment stage was improved by:
•	adding proper SSM status polling
•	increasing wait times
•	printing detailed SSM output on failure
This made backend deployment failures easier to diagnose.

5. CloudFront Returning 403 Access Denied
Challenge:
The frontend initially failed to load because CloudFront returned a 403 AccessDenied error.
Root Cause:
CloudFront could not access the frontend content correctly in S3.
Solution:
The following changes were made:
•	set CloudFront default root object to index.html
•	fixed S3 bucket permissions
•	configured the bucket for static website hosting

6. Vite Environment Variable Not Loading
Challenge:
The frontend could not connect to the backend because the API base URL was undefined.
Root Cause:
The frontend used:
import.meta.env.production.VITE_API_BASE_URL
which is not valid in Vite.
Solution:
The code was updated to:
import.meta.env.VITE_API_BASE_URL
This correctly loaded variables from .env.production.

7. Backend API Returning 500 Errors
Challenge:
Frontend API requests returned 500 Internal Server Error.
Root Cause:
The backend connected successfully to PostgreSQL, but database tables such as tasks and projects did not exist.
Solution:
The backend deployment was updated to set:
RUN_DB_INIT=true
This ensured that the database initialization logic ran automatically during startup and created required tables.

8. Database Initialization Was Being Skipped
Challenge:
Although the backend contained SQL code to create tables, the logs showed:
Skipping database initialization
Root Cause:
Database initialization only occurred when:
RUN_DB_INIT === "true"
Solution:
The backend deployment script was updated to include:
-e RUN_DB_INIT=true
inside the Docker container startup command.

9. Jenkins Was Using an Outdated Deployment Script
Challenge:
Even after updating deploy-backend.sh locally, the backend deployment continued using an older version.
Root Cause:
The app EC2 instance already contained an old copy of:
/home/ec2-user/deploy-backend.sh
and SSM always executed that existing file.
Solution:
The Jenkins pipeline was redesigned to upload the latest version of deploy-backend.sh to the app EC2 instance during every deployment before executing it.
This removed configuration drift between:
•	Git repository
•	Jenkins workspace
•	EC2 instance

10. Wrong Secret Value Passed to Backend Deployment
Challenge:
The deployment script originally received an EC2 instance ARN instead of the application secret ARN.
Solution:
The Jenkins pipeline was corrected to pass the proper AWS Secrets Manager ARN for the application configuration secret.
Ran the command in aws CLI:
aws secretsmanager list-secrets \
  --region eu-central-1 \
  --query 'SecretList[*].[Name,ARN]' \
  --output table


## Future Improvements
Although the current platform already provides a production-style AWS deployment with Terraform, Jenkins CI/CD, Docker, S3, CloudFront, RDS, ALB, Secrets Manager, and EC2 Auto Scaling, several future improvements can make the system even more scalable, secure, and production-ready.
1. End-to-End HTTPS
The frontend already uses CloudFront, but the backend can be further improved by adding:
•	AWS Certificate Manager (ACM)
•	HTTPS listener on the Application Load Balancer
•	Automatic HTTP to HTTPS redirection
•	Secure cookies and HSTS headers
This would provide secure communication across the entire platform.

2. Kubernetes-Based Deployment
The current deployment uses Docker containers on EC2 instances.
In the future, the platform could be migrated to:
•	Amazon Elastic Kubernetes Service (EKS)
•	Kubernetes
This would provide:
•	easier scaling
•	rolling deployments
•	self-healing containers
•	better resource utilization
•	improved container orchestration

3. Container Image Security Scanning
Currently, Docker images are built and deployed automatically.
Future enhancements could include:
•	container vulnerability scanning
•	image signing
•	dependency scanning
•	secret detection in source code
•	Software Bill of Materials (SBOM) generation
Possible tools include:
•	Trivy
•	SonarQube
•	OWASP Dependency-Check

4. Infrastructure Security Improvements
The current setup already uses IAM roles, Security Groups, and Secrets Manager.
Future security enhancements may include:
•	private subnets for all application instances
•	VPC endpoints for AWS services
•	Web Application Firewall (WAF)
•	intrusion detection with GuardDuty
•	stricter IAM least-privilege policies
•	AWS Config compliance checks
Possible services include:
•	AWS WAF
•	Amazon GuardDuty
•	AWS Config

5. Event-Driven and Serverless Features
Some background tasks can eventually be moved to serverless services such as:
•	AWS Lambda
•	Amazon SQS
•	Amazon EventBridge
This could improve scalability and reduce operational overhead for asynchronous processing tasks.

