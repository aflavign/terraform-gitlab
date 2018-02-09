provider "aws" {
  region = "${var.region}"
}

# Configure backend
terraform {
  backend "s3" {
    region = "eu-central-1"
  }
}

module "config" {
  source = "../modules/config"
}

module "ami" {
  source = "../modules/ami"
}

module "security_group" {
  source      = "../modules/security_group"
  vpc_id      = "${module.config.vpc_id}"
  name        = "gitlab-ce"
  region      = "${var.region}"
  cidr_blocks = "${var.infra_vpc_cidr}"
}

resource "aws_instance" "gitlab-ce" {
  instance_type = "${var.machine_type}"
  count         = "${var.deploy_gitlab ? 1 : 0}"
  ami           = "${module.ami.id}"

  # The name of our SSH keypair
  key_name = "${var.host_key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${module.security_group.id}"]

  subnet_id = "${module.config.public_subnet_a_id}"

  # set the relevant tags
  tags = {
    Name  = "gitlab_ce"
    Owner = "${var.tag_Owner}"
  }

  provisioner "file" {
    source      = "bootstrap"
    destination = "/tmp/bootstrap"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap",
      "sudo /tmp/bootstrap ${aws_instance.gitlab-ce.private_ip}",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key}")}"
    }
  }
}

output "address" {
  value = "${aws_instance.gitlab-ce.private_ip}"
}

# vim: sw=4 ts=4

