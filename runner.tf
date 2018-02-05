data "template_file" "runner_host" {
  template = "$${runner_host == "GENERATE" ? generated_host : runner_host}"

  vars {
    runner_host    = "${var.runner_host}"
    generated_host = "http${var.ssl_certificate != "/dev/null" ? "s" : ""}://${var.dns_name}"
  }
}

resource "aws_instance" "gitlab-ci-runner" {
  name          = "runner"
  count         = "${var.runner_count}"
  instance_type = "${var.machine_type}"
  ami           = "${data.aws_ami.ubuntu.id}"

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
    source      = "${path.module}/bootstrap_runner"
    destination = "/tmp/bootstrap_runner"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap_runner",
      "sudo /tmp/bootstrap_runner ${aws_instance.gitlab-ci-runner.name} ${data.template_file.runner_host.rendered} ${data.template_file.gitlab.vars.runner_token} ${var.runner_image}",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "sudo gitlab-ci-multi-runner unregister --name ${aws_instance.gitlab-ci-runner.name}",
    ]
  }
}

output "runner_disk_size" {
  value = "${var.runner_disk_size}"
}

output "runner_image" {
  value = "${var.runner_image}"
}

output "runner_host" {
  value = "${data.template_file.runner_host.rendered}"
}
