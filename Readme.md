# Infrastructure as code using Terraform

![iac-diagram](iac-diagram.png?raw=true "iac-diagram")

## Steps
### Setup/Configurations
*Create a User*  
*Install Terraform if it's nt installed on ur system: https://www.terraform.io/cli/install/apt*  
*Install AWS Toolkit from VS Code Extension*  
*Click the AWS icon on the left pane*  
*Go to View on the top bar -> Command pallete. Search for AWS: create credential profile*  
*Enter the access and secret keys*  
*Install Terraform (d one with 4.5 rating) from VS Code Extension*  

*4 documtatn: https://registry.terraform.io/providers/hashicorp/aws/latest/docs*  

Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS e.g Interact with Lambda, RDS, and IAM etc. You must configure the provider with the proper credentials before you can use it. There other providers for other cloud services like Google, Azure etc.  

### file structure
terraform.tfvars  
providers.tf  
variables.tf  
main.tf    

*copy the provider codd and save in providers.tf file*  
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

### Configure the AWS Provider: Shared Configuration and Credentials Files
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "terraform"
}

*dn run `terraform init` in terminal*  

### Deploy VPC
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "babs_vpc" {
  cidr_block = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "dev"
  }
}


run `terraform plan`  

![terra1](terra1.png?raw=true "terra1")
![terra2](terra2.png?raw=true "terra2")

run `terraform apply` then type yes

![terra3](terra3.png?raw=true "terra3")

Go to aws icon on the left pane of vscode. click the region e.g US East(N.Virginia) then Resources  

![terra4](terra4.png?raw=true "terra4")
![terra5](terra5.png?raw=true "terra5")

### Terraform State
https://www.terraform.io/language/state

Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.  

This state is stored by default in a local file named "terraform.tfstate", but it can also be stored remotely, which works better in a team environment.  

Terraform uses this local state to create plans and make changes to your infrastructure. Prior to any operation, Terraform does a refresh to update the state with the real infrastructure.  

*Inspection and Modification*  
While the format of the state files are just JSON, direct file editing of the state is discouraged. Terraform provides the terraform state command to perform basic modifications of the state using the CLI.  

![terra6](terra6.png?raw=true "terra6")

to list what is in the resources  
`terraform state list`  

![terra7](terra7.png?raw=true "terra7")

to show what is in the vpc created  
`terraform state show aws_vpc.babs_vpc`

to see the entire state  
`terraform show`

https://www.terraform.io/cli/commands/destroy  
to destroy the created environment  
`terraform destroy`

to set up the resources again  
`terraform apply`


### Deploy subnet
resource "aws_subnet" "babs_public_subnet" {
  vpc_id     = aws_vpc.babs_vpc.id
  cidr_block = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev-public-subnet"
  }
}

run `terraform plan`

run `terraform apply` 
if dont want to type `yes` when u run terrafom
`terraform apply -auto-approve`

![terra8](terra8.png?raw=true "terra8")

### Internet Gateway and Terraform fmt
`terraform fmt` format any inconsistencies in the directory

`terraform plan`
`terraform apply`

### Route Table
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route


*Bridging gap btw route table and subnet*  
### Route Table Associatin

### Sec grp

### ami image
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami

check inside datasources.tf

Basic Example Using AMI Lookup
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}

u need owners value:  
go to ec2 dashboard, launch ec2 instance under, 
Application and OS Images (Amazon Machine Image) section 
select Ubuntu AMI (any free tier). copy ami-08d4ac5b634553e16.

Go back to the AMIs under Images. Change Owned by me dropdown 
to public Images and paste the ami u copied `ami-08d4ac5b634553e16`
into the search input. Locate the ami and go to the owner section
to copy the number display, 099720109477.

data "aws_ami" "server-ami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

}

run `terraform apply`

### key pair
run in the terminal `ssh-keygen -t ed25519` returns:  
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/aduke/.ssh/id_ed25519): 

rename the path by entering ds: /home/aduke/.ssh/babskey

Enter file in which to save the key (/home/aduke/.ssh/id_ed25519): /home/aduke/.ssh/babskey

run `ls ~/.ssh`
babskey  babskey.pub


### EC2 Instance
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}

run `terraform state show aws_key_pair.babs_keypair`

### User Data
Create userdata template, userdata.tpl

to see the instance public ip:   
`terraform state list`
to get the instance name  
`aws_instance.dev-terraform-instance`

then run: `terraform state show aws_instance.dev-terraform-instance`

go to: public_ip = "107.22.87.56" and copy

### SSH into d ec2
ssh -i ~/.ssh/babskey ubuntu@107.22.87.56

docker --version

### SSH Config Scripts
cat ~/.aws/config

cat << EOF >> ~/.aws/config

Host ${hostname}
    Hostname ${hostname}
    User ${user}
    IdentifyFile ${identifyFile}
EOF

### Provisioners
https://www.terraform.io/language/resources/provisioners/syntax



![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")



![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")


![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")
![terra4](terra4.png?raw=true "terra4")



=====================
ssh-config.tpi
userdata.tpi



