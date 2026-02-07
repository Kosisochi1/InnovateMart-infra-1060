#############################################
#     Bedrock Project .
#############################################

#############################################
# 0. Terraform Backend (PRE-CREATE BUCKET & DDB)
#############################################
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
    bucket         = "bedrock-tf-state-1060"
    key            = "project-bedrock/terraform.tfstate"
    region         = "us-east-1"
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

#############################################
# 2. VPC
#############################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "project-bedrock-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = "Bedrock"
  }
}

#############################################
# 3. EKS Cluster
#############################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "project-bedrock-cluster"
  cluster_version = "1.34"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 2
      max_size     = 4

      instance_types = ["t3.small"]
    }
  }


  cluster_endpoint_private_access      = false         # disable private access
  cluster_endpoint_public_access       = true          # enable public access
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # allow all IPs

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  tags = {
    Project = "Bedrock"
  }
}

#############################################
# 4. Kubernetes & Helm Providers
#############################################

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.eks.cluster_certificate_authority_data
  )
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

provider "helm" {
  kubernetes = {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(
      module.eks.cluster_certificate_authority_data
    )
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}

#############################################
# 5. Namespace
#############################################
resource "kubernetes_namespace" "retail" {
  metadata {
    name = "retail-app"
  }

  depends_on = [module.eks, aws_eks_addon.cw_observability]

}

#############################################
# 6. Retail Store Sample App (Helm)
#############################################
resource "helm_release" "retail_store" {
  name      = "retail-store"
  namespace = kubernetes_namespace.retail.metadata[0].name


  chart   = "oci://ghcr.io/kosisochi1/charts/retail-store"
  version = "0.1.0"


  depends_on = [kubernetes_namespace.retail]

}

#############################################
# 7. IAM User – bedrock-dev-view
#############################################


resource "aws_eks_access_entry" "kosi_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::710271940761:user/Kosi_user"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "kosi_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::710271940761:user/Kosi_user"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_user" "dev_view" {
  name = "bedrock-dev-view"
  tags = { Project = "Bedrock" }
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "dev_view" {
  user = aws_iam_user.dev_view.name
}

#############################################
# 8. EKS Read‑Only Access Mapping
#############################################



resource "aws_eks_access_entry" "dev_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.dev_view.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "dev_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_user.dev_view.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  depends_on = [module.eks.eks_managed_node_groups]
}
resource "aws_iam_role_policy_attachment" "cloudwatch_full_access" {
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  depends_on = [module.eks.eks_managed_node_groups]
}






#############################################
# 9. CloudWatch Observability Add-on
#############################################





resource "aws_eks_addon" "cw_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [module.eks.eks_managed_node_groups]

  timeouts {
    create = "30m"
    update = "30m"
  }
}

#############################################
# t S3 Bucket – Assets
#############################################
resource "aws_s3_bucket" "assets" {
  bucket = "bedrock-assets-1060"

  tags = {
    Project = "Bedrock"
  }
}



#############################################
# S3 Bucket access For Lamda test 
#############################################


resource "aws_iam_policy" "dev_s3_write" {
  name        = "bedrock-dev-s3-write"
  description = "Allow devs to upload objects to bedrock-assets bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.assets.arn,
          "${aws_s3_bucket.assets.arn}/*"
        ]
      }
    ]
  })
}



resource "aws_iam_policy_attachment" "dev_s3_write_attach" {
  name       = "bedrock-dev-s3-write-attach"
  users      = [aws_iam_user.dev_view.name]
  policy_arn = aws_iam_policy.dev_s3_write.arn
}

#############################################
#  Lambda – bedrock-asset-processor
#############################################
resource "aws_iam_role" "lambda_role" {
  name = "bedrock-asset-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Project = "Bedrock" }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



resource "aws_lambda_function" "processor" {
  function_name = "bedrock-asset-processor"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs20.x"
  handler       = "index.handler"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")


  tags = { Project = "Bedrock" }
}






resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

#############################################
#  OUTPUTS 
#############################################
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "region" {
  value = "us-east-1"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "assets_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}



