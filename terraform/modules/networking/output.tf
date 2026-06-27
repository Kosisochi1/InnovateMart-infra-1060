output "vpc_id" {
  value = module.vpc.vpc_id

}


output "vpc_name" {
  value = module.vpc.name

}

output "private_subnets" {

  value = module.vpc.private_subnets

}
