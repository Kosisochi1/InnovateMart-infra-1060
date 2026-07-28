

# output "region" {
#   value = aws_region
# }



output "assets_bucket_name" {
  value = module.storage.assets_bucket_name
}


# output "ingress" {

#   value = module.compute.ingress

# }

output "cluster_endpoint" {
  value = module.compute.cluster_endpoint

}

output "cluster_name" {
  value = module.compute.cluster_name

}

output "dns_name" {
  value = module.kubernetes.alb_dns_names

}
output "node_security_group_id" {
  value = module.compute.eks_managed_node_groups
}








# output "ingress" {


# value = try(kubernetes_ingress_v1.retail_ui.status[0].load_balancer[0].ingress[0].hostname, "ALB not created yet")

# }
