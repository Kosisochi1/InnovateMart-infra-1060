# 🚀 Project Bedrock – InnovateMart EKS Deployment
## 📌 Overview

Project Bedrock is InnovateMart Inc.’s inaugural production-grade Kubernetes deployment on AWS. The objective of this project is to provision a secure, scalable, and observable microservices environment using Amazon EKS while implementing Infrastructure as Code (IaC), CI/CD automation, and event-driven serverless processing.

The platform deploys the AWS Retail Store Sample Application using Helm and extends the architecture with an S3-triggered Lambda function for automated asset processing.

## 🏗 Architecture Summary

The solution consists of:

* Amazon VPC spanning multiple Availability Zones

* Amazon EKS cluster for microservices workloads

* AWS Load Balancer Controller with ALB Ingress

* Retail Store Sample Application deployed via Helm

* Amazon S3 for asset uploads

* AWS Lambda for event-driven processing

* Amazon CloudWatch for centralized logging

* Terraform-managed infrastructure

* GitHub Actions CI/CD pipeline

High-Level Architecture
```
Internet
    │
    ▼
Application Load Balancer (HTTPS / ACM TLS)
    │
Kubernetes Ingress (EKS)
    │
Retail Store Microservices (Pods)
    │
CloudWatch Logs

```

```
S3 Bucket ───► Lambda (Asset Processor) ───► CloudWatch Logs
```

## 🧰 Technology Stack

| Category                | Technology                   |
| ----------------------- | ---------------------------- |
| Infrastructure as Code  | Terraform                    |
| Container Orchestration | Amazon EKS                   |
| Networking              | Amazon VPC                   |
| Ingress                 | AWS Load Balancer Controller |
| Deployment              | Helm                         |
| Serverless              | AWS Lambda (Node.js)         |
| Storage                 | Amazon S3                    |
| Observability           | Amazon CloudWatch            |
| CI/CD                   | GitHub Actions               |



## 🌍 AWS Configuration
| Resource        | Value                   |
| --------------- | ----------------------- |
| Region          | us-east-1               |
| EKS Cluster     | project-bedrock-cluster |
| VPC             | project-bedrock-vpc     |
| Namespace       | retail-app              |
| Lambda Function | bedrock-asset-processor |
| S3 Bucket       | bedrock-assets-1060     |


All resources are tagged:

Project = Bedrock

## ⚙️ Infrastructure Provisioning

* Infrastructure is provisioned using Terraform with:

* Remote state stored in S3

* State locking using DynamoDB

* Modular AWS resource provisioning

## Components Provisioned

✅ VPC with public and private subnets

✅ NAT Gateway

✅ EKS Cluster (v1.34+)

✅ Managed Node Groups

✅ IAM roles with least privilege

✅ CloudWatch Observability Add-on

✅ S3 Bucket and Lambda integration


## ☸️ Application Deployment

The Retail Store Sample Application is deployed using Helm into:
```
Namespace: retail-app
```


Services include:

* UI

* Catalog

* Cart

* Checkout

* Redis

* RabbitMQ

* Databases (in-cluster)

## The application is exposed publicly through:

✅ AWS Application Load Balancer

✅ Kubernetes Ingress



## 🔐 Secure Developer Access

An IAM user is created:
```
bedrock-dev-view
```

## Access Levels

#### AWS Console Access

✅ AWS Managed Policy:
```
ReadOnlyAccess
```

#### Kubernetes Access

✅ Mapped to EKS access policy:

```
AmazonEKSViewPolicy

```

#### Permissions:

✅ View pods, deployments, services

❌ Cannot delete or modify resources

Example:

```
kubectl get pods -n retail-app   ✅
kubectl delete pod <pod-name>    ❌

```

## 📊 Observability

Logging is centralized using Amazon CloudWatch.

### Enabled Logs

* EKS Control Plane Logs

    * API

    * Audit

    * Authenticator

    * Controller Manager

    * Scheduler

* Application container logs

* Lambda execution logs

This enables full visibility into cluster and application behavior.



## ⚡ Event-Driven Architecture
### Flow

* User uploads image to S3 bucket

* S3 triggers Lambda function

* Lambda logs processed filename

Example log output:

#Image received: product1.jpg

## 🔄 CI/CD Pipeline

GitHub Actions automates infrastructure deployment.

### Workflow
| Event         | Action          |
| ------------- | --------------- |
| Pull Request  | terraform plan  |
| Merge to main | terraform apply |


Security:

AWS credentials stored as GitHub Secrets

No credentials hardcoded in repository

🚀 Deployment Steps
1. Initialize Terraform
terraform init

2. Plan Infrastructure
terraform plan

3. Apply Infrastructure
terraform apply

🌐 Accessing the Application

After deployment:

terraform output retail_ingress_address


Open in browser:

https://<alb-dns-name>

📁 Repository Structure
project-bedrock/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── lambda/
│   └── index.js
├── helm/
└── .github/workflows/

✅ Project Outcomes

Fully automated AWS infrastructure

Production-ready Kubernetes environment

Secure developer access

Centralized logging and observability

Event-driven serverless integration

CI/CD-enabled infrastructure lifecycle

👨‍💻 Author

Cloud DevOps Engineer – InnovateMart Inc.
Project: Bedrock Deployment
