resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.eks_vpc.id



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


data "aws_security_group" "existing" {
  id = "sg-04ebd5a0f93f68584"

}


resource "aws_security_group_rule" "name" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = data.aws_security_group.existing.id

}
resource "aws_security_group_rule" "pdb" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = data.aws_security_group.existing.id

}
