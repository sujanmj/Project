resource "aws_db_subnet_group" "mjfile-rds-subgrp" {
  name       = "main"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  tags = {
    Name = "Subnet group for RDS"
  }
}

resource "aws_elasticache_subnet_group" "mjfile-ecache-subgrp" {
  name       = "mjfile-ecache-subgrp"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]

}

resource "aws_db_instance" "mjfile-rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.6.34"
  instance_class         = "db.t2.micro"
  name                   = var.dbname
  username               = var.dbuser
  password               = var.dbpass
  parameter_group_name   = "default.mysql5.6"
  multi_az               = "false"
  publicly_accessible    = "false"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.mjfile-rds-subgrp.name
  vpc_security_group_ids = [aws_security_group.mjfile-backend-sg.id]
}

resource "aws_elasticache_cluster" "mjfile-cache" {
  cluster_id           = "mjfile-cache"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.5"
  port                 = 11211
  security_group_ids   = [aws_security_group.mjfile-backend-sg.id]
  subnet_group_name    = aws_elasticache_subnet_group.mjfile-ecache-subgrp.name
}

resource "aws_mq_broker" "mjfile-rmq" {
  broker_name        = "mjfile-rmq"
  engine_type        = "ActiveMQ"
  engine_version     = "5.15.0"
  host_instance_type = "mq.t2.micro"
  security_groups    = [aws_security_group.mjfile-backend-sg.id]
  subnet_ids         = [module.vpc.private_subnets[0]]

  user {
    username = var.rmquser
    password = var.rmqpass
  }
}