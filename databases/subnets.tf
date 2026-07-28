
# Using existing Subnets
resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = data.aws_subnets.eks_subnets.ids #[aws_subnet.private_mysqll.id, aws_subnet.private_pstsql.id]

  tags = {
    Name = "db-subnet-group"
  }


}
