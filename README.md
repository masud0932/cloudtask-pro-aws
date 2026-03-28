# CloudTask Pro on AWS  
### Production-Style 3-Tier Cloud Application with Terraform, Jenkins, Docker, Auto Scaling, ALB, CloudFront, and RDS

CloudTask Pro is a **production-style AWS cloud project** that demonstrates how to design, provision, and deploy a modern web application using **Infrastructure as Code**, **CI/CD**, **containerized backend services**, and **high-availability cloud architecture**.

This project was built to reflect the kind of architecture and delivery workflow used in real-world DevOps and Cloud Engineering environments.

---

## Why this project stands out

This is not a basic EC2 demo. It is a **production-style cloud implementation** that demonstrates:

- Designing a **3-tier AWS architecture**
- Using **Terraform** to provision infrastructure consistently
- Running a **React frontend** through **S3 + CloudFront**
- Running a **Node.js backend** behind an **Application Load Balancer**
- Deploying backend instances with **Auto Scaling Group**
- Using **Amazon RDS PostgreSQL** for persistent storage
- Managing secrets with **AWS Secrets Manager**
- Implementing **Jenkins CI/CD**
- Enabling **monitoring and alerting** with **CloudWatch + SNS**
- Following strong cloud design principles such as:
  - public/private subnet separation
  - least-privilege IAM
  - secure database placement
  - scalable application tier
  - infrastructure modularity

---

## Project overview

CloudTask Pro is a task management platform where users can:

- view task dashboard metrics
- create and manage tasks
- organize work by projects
- interact with a backend API connected to PostgreSQL

The project focuses not only on application functionality, but also on how to build and operate the application in a **cloud production-style environment**.

---

## Architecture

### High-level flow

#### Frontend
```text
User → CloudFront → S3 (React frontend)
````

#### Backend API

```text
User → Application Load Balancer → EC2 Auto Scaling Group → RDS PostgreSQL
```

---

## AWS architecture components

### Networking

* Amazon VPC
* 2 Availability Zones
* 2 Public Subnets
* 2 Private App Subnets
* 2 Private DB Subnets
* Internet Gateway
* NAT Gateway
* Route Tables and Associations

### Frontend delivery

* Amazon S3
* Amazon CloudFront

### Application layer

* Application Load Balancer
* Target Group
* Launch Template
* Auto Scaling Group
* EC2 instances running Dockerized backend

### Database layer

* Amazon RDS PostgreSQL
* DB Subnet Group
* Parameter Group
* Multi-AZ deployment

### Security and access

* IAM Roles and Instance Profiles
* Security Groups
* AWS Secrets Manager
* AWS Systems Manager (SSM)

### Monitoring and alerting

* Amazon CloudWatch Logs
* CloudWatch Alarms
* Amazon SNS

### CI/CD and automation

* Jenkins
* Terraform
* Docker

---

## Architecture diagram

Add your architecture image here after you create it:

```md
![Architecture Diagram](diagrams/architecture.png)
```

Recommended diagram blocks:

* CloudFront → S3 frontend
* ALB → EC2 ASG in private subnets
* EC2 → RDS PostgreSQL in private DB subnets
* Jenkins server
* Secrets Manager
* CloudWatch / SNS
* Terraform provisioning flow

---

## Tech stack

### Application

* React
* Vite
* Node.js
* Express
* PostgreSQL

### Cloud & Infrastructure

* AWS
* Terraform
* EC2
* ALB
* Auto Scaling
* RDS
* S3
* CloudFront
* IAM
* Secrets Manager
* CloudWatch
* SNS
* SSM

### CI/CD & DevOps

* Jenkins
* Docker
* Git
* GitHub

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

---

## CI/CD workflow

Jenkins is used to automate application delivery.

### Pipeline flow

```text
Developer pushes code
        ↓
     Jenkins
        ↓
Build backend Docker image
        ↓
Push image
        ↓
Build frontend
        ↓
Upload frontend build to S3
        ↓
Invalidate CloudFront cache
        ↓
Deploy backend to EC2 instances
```

### CI/CD goals

* reduce manual deployment effort
* improve repeatability
* support faster changes
* reflect real DevOps delivery practices

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