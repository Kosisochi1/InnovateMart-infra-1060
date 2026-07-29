# Retail Store Microservices Infrastructure Runbook
## Overview

This runbook provides the operational procedures for deploying, managing, troubleshooting, and destroying the Retail Store Microservices infrastructure deployed on AWS using Terraform and Kubernetes.

## Perequisites

Ensure the following are installed.
* Terraform
* AWS CLI
* kubectl
* Helm 
* Git 


## AWS Authentication

Configure AWS Credential

```
aws configure
```
Verify access

```
aws sts get-caller-identity
```

## Clone Repository

```
git clone 

cd backend file
```

## Initialize Terraform Backend for State Management
```
terraform init
```
Expected Result 

Terraform has been successfully initialized


## Validate Configuration
```
terraform fmt -recursive

terraform validate
```

## Review Executive Plan
```
terraform plan -out=tfplan
```
Review the resources to be created


## Deploy Infrastructure

```
terraform apply tfplan
```
Deployment takes some minutes
 
### Note
Bucket name will be used in Retail Store Backend state management.


## Initialize Terraform for the Database 

```
cd database

terraform init
```
Expected Result 

Terraform has been successfully initialized


## Validate Configuration
```
terraform fmt -recursive

terraform validate
```

## Review Executive Plan
```
terraform plan -out=tfplan
```
Review the resources to be created


## Deploy Infrastructure

```
terraform apply tfplan
```
Deployment takes some minutes


## Initialize Terraform for the Database 

```
cd terraform

terraform init
```
Expected Result 

Terraform has been successfully initialized


## Validate Configuration
```
terraform fmt -recursive

terraform validate
```

## Review Executive Plan
```
terraform plan -out=tfplan
```
Review the resources to be created


## Deploy Infrastructure

```
terraform apply tfplan
```
Deployment takes some minutes



## Resources Created 

* VPC
* Internet Gateway
* NAT Gateway
* Security Groups
* EKS Cluster
* Managed Node Groups
* IAM Roles
* RDS MySQL
* RDS PostgreSQL
* DynamoDB
* AWS Load Balancer Controller
* Kubernetes Namespace 
* Helm Releases


## Configure kubectl

```
aws eks update-kubeconfig \
    --region us-east-1 \
    --name cluster name
```
Verify connection

```
kubectl get nodes

```


## Verify Cluster Health

Nodes 
kubectl get nodes

Pods 
kubectl get pods -A

Services 
kubectl get svc -A

Ingress 

kubectl get ingress -A

## Retrieve ALB DNS

```
kubectl get ingress name -n retail-app
```
Open the returned URL in a browser

## Issues and Trouble Shooting 

### CrashLoopBackOff
  * check Events
  ```
  kubectl describe pod pod_name
  ```
  * Check Logs
  ```
  kubectl logs pod_name
  ```
### Database Connection Failure

* Security Groups
* Database endpoint
* Username/password
* Network ACLs
* IAM permissions


### EKS Authentication Error

* Refresh kubeconfig.

```
aws eks update-kubeconfig \
--region us-east-1 \
--name retail-store-cluster
```
## Destroy Infrastructure 
 
 ```
 cd script folder
 ```
Run the terraform destroy script


