output "cluster_name" {
  value = module.eks.cluster_name

}
output "module_eks" {

  value = module.eks
}


output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups["default"].iam_role_name

}


output "eks_managed_node_group" {

  value = module.eks.eks_managed_node_groups

}


output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn

}
output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url

}




output "debug_vpc_id" {
  value = var.vpc_id
}

output "debug_subnets" {
  value = var.private_subnets
}






output "region" {
  value = "us-east-1"
}

# output "vpc_id" {
#   value = module.vpc.vpc_id
# }


output "eks" {
  value = module.eks

}




output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data

}



