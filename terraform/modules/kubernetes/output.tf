# output "ingress" {

#   value = try(kubernetes_ingress_v1.retail_ui.status[0].load_balancer[0].ingress[0].hostname, "ALB not created yet")

# }


output "alb" {

  value = helm_release.aws_load_balancer_controller.name
}



output "alb_dns_names" {
  value = try(
    data.kubernetes_ingress_v1.retail_ui.status[0].load_balancer[0].ingress[0].hostname,
    null
  )
}
