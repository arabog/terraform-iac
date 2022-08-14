resource "aws_vpc" "babs_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}


resource "aws_subnet" "babs_public_subnet" {
  vpc_id                  = aws_vpc.babs_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "dev-public-subnet"
  }
}


resource "aws_internet_gateway" "babs_igw" {
  vpc_id = aws_vpc.babs_vpc.id

  tags = {
    Name = "dev-internet-gateway"
  }
}


resource "aws_route_table" "babs_rt" {
  vpc_id = aws_vpc.babs_vpc.id

  tags = {
    Name = "dev-route-table"
  }
}


resource "aws_route" "default-route" {
  route_table_id         = aws_route_table.babs_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.babs_igw.id
}


resource "aws_route_table_association" "babs_rt_association" {
  subnet_id      = aws_subnet.babs_public_subnet.id
  route_table_id = aws_route_table.babs_rt.id
}


resource "aws_security_group" "babs_sec_grp" {
  name        = "dev_sg"
  description = "dev sec grp"
  vpc_id      = aws_vpc.babs_vpc.id

  #   ingress {
  #     description = "Bab Sec Ingress from VPC"
  #     from_port   = 0
  #     to_port     = 0
  # protocol         = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #     protocol    = "-1"
  #   }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "dev-sec-grp"
  }
}

resource "aws_key_pair" "babs_keypair" {
  key_name   = "babs-key"
  public_key = file("~/.ssh/babskey.pub")

  #   https://www.terraform.io/language/functions/file
  #   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_instance" "dev-terraform-instance" {
  ami                    = data.aws_ami.server-ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.babs_keypair.id
  vpc_security_group_ids = [aws_security_group.babs_sec_grp.id]
  subnet_id              = aws_subnet.babs_public_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-instance"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname = self.public_ip,
      # instance type is ubuntu
      user = "ubuntu",
      identifyFile = "~/.ssh/babskey"
    })

    interpreter = ["bash", "-c"]
  }
}


