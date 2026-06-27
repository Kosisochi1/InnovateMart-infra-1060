

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

output "dns" {
  value = module.kubernetes.ingress

}


# output "ingress" {


# value = try(kubernetes_ingress_v1.retail_ui.status[0].load_balancer[0].ingress[0].hostname, "ALB not created yet")

# }
