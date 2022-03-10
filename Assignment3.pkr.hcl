packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source = "github.com/hashicorp/amazon"
    }
  }
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "ami_users" {
  type = list(string)
}

source "amazon-ebs" "ubuntu" {
  ami_name = "csye6225_{{timestamp}}"
  access_key = var.access_key
  secret_key = var.secret_key
  instance_type = "t2.micro"
  region = "us-east-1"
  source_ami = "ami-083654bd07b5da81d"
  ssh_username = "ubuntu"
  ami_users = var.ami_users
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update -y && sudo apt upgrade -y",
      "sudo apt install ruby-full -y",
      "sudo apt install wget -y",
      "cd /home/ubuntu",
      "wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install",
      "chmod +x ./install",
      "sudo ./install auto > /tmp/logfile",
      "sudo service codedeploy-agent status",
      "wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb",
      "sudo dpkg -i -E ./amazon-cloudwatch-agent.deb",
      "sudo systemctl enable amazon-cloudwatch-agent.service",
      "sudo apt install openjdk-16-jre-headless -y",
      "java -version",
    ]
  }
}