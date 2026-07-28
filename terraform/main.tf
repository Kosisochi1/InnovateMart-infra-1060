#############################################
#     Bedrock Project
#############################################

#############################################
# 0. Terraform Backend (PRE-CREATE BUCKET & DDB)
#############################################

# }

data "aws_caller_identity" "current" {}


terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {

      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }
  }

  backend "s3" {
    bucket         = "bedrock-tf-state-kosi-1060"
    key            = "project-bedrock/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "bedrock-tf-lock"
    encrypt        = true
  }
}

#############################################
# 1. Providers
#############################################
provider "aws" {
  region = "us-east-1"
}
data "aws_eks_cluster" "cluster" {
  name       = var.cluster_name
  depends_on = [module.compute.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = var.cluster_name
  depends_on = [module.compute.eks]
}






provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )

  # token = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.cluster_name
    ]
  }
}

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.cluster.certificate_authority[0].data
    )

    # token = data.aws_eks_cluster_auth.cluster.token
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name
      ]
    }
  }
}

module "networking" {
  source       = "./modules/networking/"
  cluster_name = var.cluster_name

}

module "iam" {
  source       = "./modules/iam"
  cluster_name = module.compute.cluster_name
}
module "compute" {
  source          = "./modules/compute/"
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets
  dev_view        = module.iam.dev_view_arn
  cluster_name    = var.cluster_name

}

# module "monitoring" {
#   source                  = "./modules/monitoring"
#   cluster_name            = module.compute.cluster_name
#   eks_managed_node_groups = module.compute.eks_managed_node_groups
#   eks_managed_node_group  = module.compute.eks_managed_node_group

# }
module "storage" {
  source        = "./modules/storage"
  dev_view_name = module.iam.dev_view


}


module "kubernetes" {
  source = "./modules/kubernetes"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
  cluster_name     = module.compute.cluster_name
  cluster_endpoint = module.compute.cluster_endpoint


  # cluster_certificate_auth = module.compute.cluster_certificate_auth
  # dev_view = module.iam.dev_view
  # eke= module.compute.eks_managed_node_group
  oidc_provider_arn       = module.compute.oidc_provider_arn
  cluster_oidc_issuer_url = module.compute.cluster_oidc_issuer_url
  eks                     = module.compute.module_eks
  vpc_id                  = module.networking.vpc_id




}
















