provider "aws" {
  region = "${var.region}"
}

# get remote state to retreive id used for all accounts ressources
data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "yxdzlwvolxmz-eu-central-1-tfstate-infra"
    key    = "landing-zone/infra/infra.tfstate"
    region = "eu-central-1"
  }
}

module "ami" {
  source = "../modules/ami"
}


module "security_group" {
  source = "../modules/security_group"
  vpc_id = "${data.terraform_remote_state.infra.vpc_id}"
  name = "gitlab-ce"
}


resource "aws_instance" "gitlab-ce" {
  instance_type = "${var.machine_type}"
  count         = "${var.deploy_gitlab ? 1 : 0}"
  ami           = "${module.ami.id}"

  # The name of our SSH keypair
  key_name = "${var.host_key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${module.security_group.id}"]

  subnet_id = "${data.terraform_remote_state.infra.public_subnet_a_id}"

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
      private_key = "${file("eh-frankfurt-afla.pem")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /tmp/bootstrap ${aws_instance.gitlab-ce.private_ip}"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("eh-frankfurt-afla.pem")}"
    }
  }
}

output "address" {
  value = "${aws_instance.gitlab-ce.private_ip}"
}

# vim: sw=4 ts=4

