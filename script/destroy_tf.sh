#!/bin/env bash


set -e

ROOT_DIR="../terraform"


echo "============================================"
echo "Retail Store Infrastructure Destroy"
echo "============================================"






cd "${ROOT_DIR}"

echo "[1/6] Initializing Terraform... "
terraform init

echo "[2/6] Removing Kubernetes resources..."
terraform destroy -target=module.kubernetes -auto-approve

echo "[3/6] Destroying Compute resources..."
terraform destroy -target=module.compute -auto-approve

echo "[4/6] Destroying storage..."
terraform destroy -target=module.storage -auto-approve

echo "[5/6] Destroying IAM..."
terraform destroy -target=module.iam -auto-approve

echo "[6/6] Destroying remaining Infrastructure..."
terraform destroy -auto-approve


echo "==========================================="
echo "Infrastructure Destroyed successfully"
echo "==========================================="








# terraform -chdir=terraform destroy -target=module.networking




# terraform destroy -target=helm_release.retail_store
# terraform destroy -target=kubernetes_namespace.retail



# terraform destroy --auto-approve