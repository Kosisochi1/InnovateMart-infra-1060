# Using existing EKS VPC


data "aws_vpc" "eks_vpc" {
  id = "vpc-0a3d39f79f92acc4d"

}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }

}
