resource "aws_db_instance" "mysql" {
  identifier = "mysql"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "catalog"
  username = "catalog"
  password = var.mysql_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false

  skip_final_snapshot = true

  tags = {
    Name = "mysql-db"
  }
}
