data "template_file" "runner_host" {
  template = "$${runner_host == "GENERATE" ? generated_host : runner_host}"

  vars {
    runner_host    = "${var.runner_host}"
    generated_host = "http://${aws_instance.gitlab-ce.private_ip}"
  }
}

resource "aws_instance" "gitlab-ci-runner" {
  count         = "${var.runner_count}"
  instance_type = "t2.small"
  ami           = "${data.aws_ami.rhel7.id}"

  # The name of our SSH keypair
  key_name = "${var.host_key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.gitlab_host_SG.id}"]

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
      "sudo /tmp/bootstrap_runner ${aws_instance.gitlab-ci-runner.id} ${data.template_file.runner_host.rendered} ${data.template_file.gitlab.vars.runner_token} ${var.runner_image}",
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
      "sudo gitlab-ci-multi-runner unregister --name ${aws_instance.gitlab-ci-runner.id}",
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
