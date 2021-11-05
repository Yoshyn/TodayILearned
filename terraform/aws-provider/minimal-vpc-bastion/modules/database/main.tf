data "aws_vpc" "vpc" {
  id = var.vpc_id
}

/*==== VPC's RDS Security Group ======*/
resource "aws_security_group" "database_sg" {
  name        = "${var.global_name}-database-sg"
  description = "Allow DB access"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  tags = {
    Name        = "${var.global_name}-database-sg"
    environment = "${var.environment}"
    module      = "database"
    Automation  = "Terraform"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = var.private_subnets_ids

  tags = {
    Name        = "${var.global_name}-db-subnet-group"
    environment = "${var.environment}"
    module      = "database"
    Automation  = "Terraform"
  }
}

resource "aws_db_instance" "database" {
  identifier        = "${lower(var.global_name)}-${lower(var.environment)}-${formatdate("YYYY-MM-DD", timestamp())}"
  name              = var.database_name # (Optional) The name of the database to create when the DB instance is created.
  instance_class    = "db.t3.micro"     # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
  allocated_storage = 20                # The allocated storage in gibibytes.
  engine            = "postgres"        # "postgres", "mysql", "aurora", etc. https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html

  # The master account username and password.
  # Note that these settings may show up in logs,
  # and will be stored in the state file in raw text.
  username = var.database_root_username
  password = var.database_root_password

  publicly_accessible = false

  allow_major_version_upgrade = true

  backup_retention_period = 15

  backup_window      = "08:00-09:00"
  maintenance_window = "sun:09:00-sun:10:00"

  port                   = 5432
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  skip_final_snapshot = true

  tags = {
    Name        = "${var.global_name}-db-instance"
    environment = "${var.environment}"
    module      = "database"
    Automation  = "Terraform"
  }
}

resource "aws_secretsmanager_secret" "database_private_key" {
  name                    = "/${var.global_name}/${var.environment}/database/connection_string"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.global_name}-database_private_key"
    environment = "${var.environment}"
    module      = "database"
    Automation  = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "database_private_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.database_private_key.id
  secret_string = "PGPASSWORD=${aws_db_instance.database.password} psql -Atx -U ${aws_db_instance.database.username} -h ${aws_db_instance.database.address} -p ${aws_db_instance.database.port}"
}