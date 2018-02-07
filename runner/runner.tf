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

data "template_file" "runner_host" {
  template = "$${runner_host == "GENERATE" ? generated_host : runner_host}"

  vars {
    runner_host    = "${var.runner_host}"
    generated_host = "http://${var.gitlab-ce_private_ip}"
  }
}

module "security_group" {
  source = "../modules/security_group"
  vpc_id = "${data.terraform_remote_state.infra.vpc_id}"
  name   = "gitlab runner"
}

module "ami" {
  source = "../modules/ami"
}

resource "aws_instance" "gitlab-ci-runner" {
  count         = "${var.runner_count}"
  instance_type = "t2.small"
  ami           = "${module.ami.id}"

  # The name of our SSH keypair
  key_name = "${var.host_key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${module.security_group.id}"]

  subnet_id = "${data.terraform_remote_state.infra.public_subnet_a_id}"

  # associate_public_ip_address = false
  # set the relevant tags
  tags = {
    Name  = "gitlab_runner"
    Owner = "${var.tag_Owner}"
  }

  provisioner "file" {
    source = "bootstrap_runner"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("eh-frankfurt-afla.pem")}"
    }

    destination = "/tmp/bootstrap_runner"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_runner",
      "sudo /tmp/bootstrap_runner ${aws_instance.gitlab-ci-runner.id} ${data.template_file.runner_host.rendered} ${var.runner_token} ${var.runner_image}",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("eh-frankfurt-afla.pem")}"
    }
  }

  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "sudo gitlab-ci-multi-runner unregister --name ${aws_instance.gitlab-ci-runner.id} || true",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("eh-frankfurt-afla.pem")}"
    }
  }
}

output "runner_image" {
  value = "${var.runner_image}"
}

output "runner_host" {
  value = "${data.template_file.runner_host.rendered}"
}
