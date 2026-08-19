#!/usr/bin/env bash


set -e

ROOT_DIR="../terraform"


echo "======================================"
echo "Retail Store Infrastructure Destroy"
echo "======================================"


CLUSTER_NAME="project-bedrock-cluster"
NAMESPACE="retail-app"
REGION="us-east-1"

cd "${ROOT_DIR}"



echo "Updating kubeconfig..."


aws eks update-kubeconfig  \
  --region ${REGION}  \
  --name ${CLUSTER_NAME} || true


echo "Delete Retail Store Helm Release..."



helm uninstall retail-store \
   -n ${NAMESPACE} || true


echo "Deleting AWS Load balancer Controller..."

helm uninstall aws-load-balancer-controller \
   -n kube-system || true

echo "Deleting Namespace..."
kubectl delete namespace ${NAMESPACE} \
  --wait=true || true



while kubectl get ns ${NAMESPACE} >/dev/null 2>&1
do 
   echo "Namespace still exist..."
   sleep 10
done


terraform init 


terraform destroy \
  -auto-approve


