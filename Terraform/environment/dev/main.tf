data "aws_caller_identity" "current" {}

# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  single_nat_gateway = true
}

# ---------------------------------------------------------
# Security Groups
# ---------------------------------------------------------

module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  admin_cidr = var.admin_cidr
}

# ---------------------------------------------------------
# EKS
# ---------------------------------------------------------

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids

  eks_nodes_security_group_id = module.security_groups.eks_nodes_security_group_id

  kubernetes_version = var.kubernetes_version

  node_instance_types = ["t3.medium"]

  desired_size = 2
  min_size     = 2
  max_size     = 4
}

# ---------------------------------------------------------
# RDS
# ---------------------------------------------------------

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  database_subnet_ids = module.vpc.database_subnet_ids

  rds_security_group_id = module.security_groups.rds_security_group_id

  db_name = "appdb"

  master_username = "admin"

  instance_class = var.rds_instance_class

  allocated_storage = 20
}

# ---------------------------------------------------------
# Bastion Host
# ---------------------------------------------------------

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_iam_role" "bastion" {
  name = "${local.name_prefix}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name_prefix}-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_instance" "bastion" {
  ami = data.aws_ssm_parameter.amazon_linux_2023.value

  instance_type = var.bastion_instance_type

  subnet_id = module.vpc.public_subnet_ids[0]

  vpc_security_group_ids = [
    module.security_groups.bastion_security_group_id
  ]

  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.bastion.name

  tags = {
    Name = "${local.name_prefix}-bastion"
  }

  depends_on = [
    aws_iam_role_policy_attachment.bastion_ssm
  ]
}

resource "aws_ecr_repository" "app" {
  name                 = "${local.name_prefix}-api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.common_tags
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}