packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "ubuntu-server-east" {
  region = "us-east-2"
  filters = {
    name = var.image_name
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-server-east" {
  region         = "us-east-2"
  source_ami     = data.amazon-ami.ubuntu-server-east.id
  instance_type  = "t2.small"
  ssh_username   = "ubuntu"
  ssh_agent_auth = false
  ami_name       = "packer_AWS_{{timestamp}}_v${var.version}"
  tags           = var.aws_tags
}

build {

  sources = [
    "source.amazon-ebs.ubuntu-server-east"
  ]

  provisioner "shell" {
    inline = [
      "echo '***** Installing nginx'",
      "sudo apt update",
      "sudo apt install nginx -y",
      # "sudo ufw allow 'Nginx HTTP'"
    ]
  }

  provisioner "file" {
    source      = "app.tar.gz"
    destination = "/tmp/app.tar.gz"
  }

  provisioner "shell" {
    inline = [
      "echo '***** Deploying nginx app'",
      "cd /tmp && sudo tar xvfz /tmp/app.tar.gz",
      "cd /tmp && sudo cp -a html /var/www",
      "sudo systemctl restart nginx"
    ]
  }
}