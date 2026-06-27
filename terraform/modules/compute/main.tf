module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name #"project-bedrock-cluster"
  cluster_version = "1.34"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_size = 3
      min_size     = 2
      max_size     = 4

      instance_types = ["t3.small"]
    }
  }



  create_cluster_security_group = true
  create_node_security_group    = true

  # cluster_security_group_id            = null
  # node_security_group_id               = null
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
    Project = "barakat-2025-capstone"
  }
}





resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = module.eks.eks_managed_node_groups["default"].iam_role_name #module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  depends_on = [module.eks]
}


resource "aws_eks_addon" "cw_observability" {
  cluster_name = module.eks.cluster_name
  addon_name   = "amazon-cloudwatch-observability"

  depends_on = [module.eks]

  timeouts {
    create = "30m"
    update = "30m"
  }

  tags = { project = "barakat-2025-capstone" }
}


resource "aws_eks_access_entry" "giovanni" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::040162742402:user/Giovanni"
  type          = "STANDARD"


  tags = {
    project = "barakat-2025-capstone"
  }
}

resource "aws_eks_access_policy_association" "giovanni" {
  cluster_name = module.eks.cluster_name

  principal_arn = "arn:aws:iam::040162742402:user/Giovanni"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

}


resource "aws_eks_access_entry" "dev_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.dev_view
  type          = "STANDARD"
  tags = {
    project = "barakat-2025-capstone"
  }
}

resource "aws_eks_access_policy_association" "dev_view" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.dev_view
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }

}








