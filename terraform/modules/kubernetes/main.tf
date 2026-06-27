


terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace" "retail" {
  metadata {
    name = "retail-app"
  }

  # depends_on = [helm_release.retail_store]

}
resource "helm_release" "retail_store" {
  name      = "retail-store"
  namespace = kubernetes_namespace.retail.metadata[0].name


  # chart   = "oci://ghcr.io/kosisochi1/charts/retail-store"
  chart   = "../retail-store"
  version = "0.1.0"


  depends_on = [kubernetes_ingress_v1.retail_ui]



}







resource "aws_iam_role" "alb_controller" {
  name = "bedrock-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })

  tags = {
    Project = "barakat-2025-capstone"
  }
}

resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("${path.module}/alb-policy.json")

  tags = {
    Project = "barakat-2025-capstone"
  }
}


resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   wait       = true
#   timeout    = 600
#   atomic     = true



#   set = [{
#     name  = "clusterName"
#     value = var.cluster_name
#     },

#     {
#       name  = "region"
#       value = "us-east-1"
#     },

#     {
#       name  = "vpcId"
#       value = var.vpc_id
#     },

#     {
#       name  = "serviceAccount.create"
#       value = "true"
#     },

#     {
#       name  = "serviceAccount.name"
#       value = "aws-load-balancer-controller"
#     },

#     {
#       name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#       value = aws_iam_role.alb_controller.arn
#     }
#   ]

#   depends_on = [aws_iam_role_policy_attachment.alb_controller]


# }


resource "kubernetes_ingress_v1" "retail_ui" {
  metadata {
    name      = "retail-ui-ingress"
    namespace = "retail-app"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80}]"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "ui"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.alb_controller]
}


