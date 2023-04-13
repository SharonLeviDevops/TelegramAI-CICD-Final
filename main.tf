######################################
# Terraform Aws Cloud infrastructure #
######################################

provider "aws" {
  region     = "us-east-2"
}
# Copy Ami's from other region
resource "aws_ami_copy" "jenkins" {
  name              = "${var.resource_alias}-ami"
  description       = "Copy of jenkins-ami"
  source_ami_id     = "ami-04e2cd5f60a36418a"
  source_ami_region = "us-west-1"

  tags = {
    Name = "${var.resource_alias}-jenkins-ec2"
  }
}


resource "aws_ami_copy" "k8s" {
  name              = "k8s-ami"
  description       = "Copy of k8s-ami"
  source_ami_id     = "ami-0f8ede470ea845029"
  source_ami_region = "us-west-1"

      tags = {
    Name = "${var.resource_alias}-k8s-ec2"
  }
}
# Create IAM role
resource "aws_iam_role" "jenkins-project-roles" {
  name = "${var.resource_alias}-roles"

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

  # Attach policy document to the IAM role
  inline_policy {
    name = "${var.resource_alias}-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ec2:*"
          ]
          Resource = "*"
        },
        {
          Sid = "VisualEditor1"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "seretsmanager:CreateSecret",
            "secretsmanager:DeleteSecret",
            "ecr:GetAuthorizationToken",
            "ecr:*",
            "s3:*",
            "sqs:*",
            "secretsmanager:ListSecrets",
            "secretsmanager:UpdateSecret",
            "ec2:Describe*",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:TerminateInstances",
            "ecr:BatchCheckLayerAvailability",
            "ecr:BatchGetImage",
            "ecr:CompleteLayerUpload",
            "ecr:Describe*",
            "ecr:GetDownloadUrlForLayer",
            "ecr:InitiateLayerUpload",
            "ecr:List*",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
          ]
          Resource = "*"
        }
      ]
    })
  }
}
resource "aws_iam_instance_profile" "terraform-jenkins-profile" {
  name = "${var.resource_alias}-profile"
  role = aws_iam_role.jenkins-project-roles.name
}
# Create Vpc mpdule
module "app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "${var.resource_alias}-vpc"
  cidr = var.vpc_cider

  azs             = var.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true

  tags = {
    Name        = "${var.resource_alias}-vpc"
    Terraform   = true
  }
}
# Create VPC peering connection
resource "aws_vpc_peering_connection" "terraform_to_app" {
  vpc_id        = module.app_vpc.vpc_id
  peer_vpc_id   = "terraform-jenkins-vpc" # Replace with the ID of the VPC you want to peer with
  peer_region   = "us-east-2" # Replace with the region where the peer VPC is located
  auto_accept   = true # Set this to false if you want to manually accept the peering connection
}

# Create security group to allow port 22,80,443
resource "aws_security_group" "terraform-securitygp-exr" {
    name = "${var.resource_alias}-sg"
    description = "${var.resource_alias}-sg"
    vpc_id = module.app_vpc.vpc_id

    ingress {
        description = "http"      
        from_port = 80
        to_port = 80     
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "jenkins"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "k8s-dash"
        from_port = 30001
        to_port = 30001
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "k8s-api"
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "https"      
        from_port = 443
        to_port = 447     
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description  = "Ssh"      
        from_port = 22
        to_port = 22     
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
      tags = {
        Name = "terraform-securitygp-exr"
      }
}

# Launch the Jenkins server instance with the first private IP
resource "aws_instance" "Jenkins-Server" {
  ami           = aws_ami_copy.jenkins.id
  instance_type = "t2.small"
  key_name      = "terraform-sharon"
  subnet_id     = module.app_vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.terraform-securitygp-exr.id]
  iam_instance_profile = aws_iam_instance_profile.terraform-jenkins-profile.name

  tags = {
    Name = "${var.resource_alias}-jenkins-ec2"
  }
}
  # Launch the k8s server instance with the second private IP
  resource "aws_instance" "k8s-Server" {
    ami           = aws_ami_copy.k8s.id
    instance_type = "t2.medium"
    key_name      = "terraform-sharon"
    subnet_id     = module.app_vpc.public_subnets[1]
    vpc_security_group_ids = [aws_security_group.terraform-securitygp-exr.id]
    iam_instance_profile = aws_iam_instance_profile.terraform-jenkins-profile.name
    tags = {
      Name = "${var.resource_alias}-k8s-ec2"
    }
  }


