resource "aws_ecr_repository" "ecr" {
  name = "ecr-repo"
}
resource "aws_iam_role" "iamrole" {
  name = "ecr-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.iamrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.iamrole.arn
  version  = "1.27"

  vpc_config {
    subnet_ids = [aws_subnet.terraform_subnet1.id,aws_subnet.terraform_subnet2.id]
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type" 
    values = ["hvm"]
  }
}
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.large"
  subnet_id                   = aws_subnet.terraform_subnet1.id
  vpc_security_group_ids      = [aws_security_group.terraform_securityGroup.id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name = "instance-key"
  tags = {
    Name = "jenkins-instance1"
  }
}
