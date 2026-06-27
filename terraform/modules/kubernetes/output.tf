output "ingress" {

  value = try(kubernetes_ingress_v1.retail_ui.status[0].load_balancer[0].ingress[0].hostname, "ALB not created yet")

}
