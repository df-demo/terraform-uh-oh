resource "aws_db_subnet_group" "demo_rds_subnet_grp" {
  name       = "demo_rds_subnet_grp_${var.environment}"
  subnet_ids = var.private_subnet

  tags = merge(var.default_tags, {
    Name = "demo_rds_subnet_grp_${var.environment}"
  })
}

resource "aws_security_group" "demo_rds_sg" {
  name   = "demo_rds_sg"
  vpc_id = var.vpc_id

  tags = merge(var.default_tags, {
    Name = "demo_rds_sg_${var.environment}"
  })

  # HTTP access from anywhere
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_kms_key" "demo_db_kms_key" {
  description             = "KMS Key for DB instance ${var.environment}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(var.default_tags, {
    Name = "demo_db_kms_key_${var.environment}"
  })
}

resource "aws_db_instance" "demo_db" {
  name                      = "demo_db_${var.environment}"
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "10.20"
  instance_class            = "db.t3.micro"
  storage_type              = "gp2"
  password                  = var.db_password
  username                  = var.db_username
  vpc_security_group_ids    = [aws_security_group.demo_rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.demo_rds_subnet_grp.id
  identifier                = "demo-db-${var.environment}"
  storage_encrypted         = true
  skip_final_snapshot       = true
  final_snapshot_identifier = "demo-db-${var.environment}-db-destroy-snapshot"
  kms_key_id                = aws_kms_key.demo_db_kms_key.arn
  tags = merge(var.default_tags, {
    Name = "demo_db_${var.environment}"
  })
}

resource "aws_ssm_parameter" "demo_ssm_db_host" {
  name        = "/demo-${var.environment}/DB_HOST"
  description = "Demo Database"
  type        = "SecureString"
  value       = aws_db_instance.demo_db.endpoint

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "demo_ssm_db_password" {
  name        = "/demo-${var.environment}/DB_PASSWORD"
  description = "Demo Database Password"
  type        = "SecureString"
  value       = aws_db_instance.demo_db.password

  tags = merge(var.default_tags, {})
}

resource "aws_ssm_parameter" "demo_ssm_db_user" {
  name        = "/demo-${var.environment}/DB_USER"
  description = "Demo Database Username"
  type        = "SecureString"
  value       = aws_db_instance.demo_db.username

  tags = merge(var.default_tags, {})
}
resource "aws_ssm_parameter" "demo_ssm_db_name" {
  name        = "/demo-${var.environment}/DB_NAME"
  description = "Demo Database Name"
  type        = "SecureString"
  value       = aws_db_instance.demo_db.name

  tags = merge(var.default_tags, {
    environment = "${var.environment}"
  })
}

resource "aws_s3_bucket" "demo_storage" {
  bucket = "demo-storage-${var.environment}-demo"
  tags = merge(var.default_tags, {
    name = "demo_blob_storage_${var.environment}"
  })
}

resource "aws_s3_bucket" "demo_public_storage" {
  bucket = "demo-public-${var.environment}-demo"
}

resource "aws_s3_bucket_public_access_block" "demo_public" {
  bucket = aws_s3_bucket.demo_public_storage.id

  ignore_public_acls = var.block_public_access
  block_public_acls   = var.block_public_access
  block_public_policy = var.block_public_access
}

resource "aws_s3_bucket_public_access_block" "demo_private" {
  bucket = aws_s3_bucket.demo_storage.id

  ignore_public_acls  = true
  block_public_acls   = true
  block_public_policy = true
}
