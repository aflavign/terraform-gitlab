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

resource "random_id" "initial_root_password" {
  byte_length = 15
}

resource "random_id" "runner_token" {
  byte_length = 15
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "gitlab" {
  template = "${file("${path.module}/templates/gitlab.rb.append")}"

  vars {
    initial_root_password = "${var.initial_root_password != "GENERATE" ? var.initial_root_password : format("%s", random_id.initial_root_password.hex)}"
    runner_token          = "${var.runner_token != "GENERATE" ? var.runner_token : format("%s", random_id.runner_token.hex)}"
  }
}

resource "aws_security_group" "gitlab_host_SG" {
  name        = "gitlab_host"
  description = "Rules for Gitlab host access"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"

  # SSH access from Public IPs and this SG
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  # HTTP access from VPC and this SG
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  # HTTPS access from Internal IPs and this SG
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  #   self        = true
  # }
  # next few rules allow access from the ELB SG
  # can't mix CIDR and SGs, so repeating a lot of the above

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 443
  #   to_port = 443
  #   protocol = "tcp"
  #   security_groups = ["${aws_security_group.gitlab_ELB_SG.id}"]
  # }

  # ingress {
  #   from_port = 443
  #   to_port = 443
  #   protocol = "tcp"
  #   security_groups = ["${aws_security_group.gitlab_ELB_SG.id}"]
  # }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "gitlab-ce" {
  instance_type = "${var.machine_type}"
  count         = "${var.deploy_gitlab ? 1 : 0}"
  ami           = "${data.aws_ami.ubuntu.id}"

  # The name of our SSH keypair
  key_name = "${var.host_key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.gitlab_host_SG.id}"]

  subnet_id = "${data.terraform_remote_state.infra.public_subnet_a_id}"

  # set the relevant tags
  tags = {
    Name  = "gitlab_runner"
    Owner = "${var.tag_Owner}"
  }

  provisioner "file" {
    content     = "${data.template_file.gitlab.rendered}"
    destination = "/tmp/gitlab.rb.append"
  }

  provisioner "file" {
    source      = "${var.config_file}"
    destination = "/tmp/gitlab.rb"
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap"
    destination = "/tmp/bootstrap"
  }

  provisioner "file" {
    source      = "${var.ssl_key}"
    destination = "/tmp/ssl_key"
  }

  provisioner "file" {
    source      = "${var.ssl_certificate}"
    destination = "/tmp/ssl_certificate"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/gitlab.rb.append >> /tmp/gitlab.rb",
      "chmod +x /tmp/bootstrap",
      "sudo /tmp/bootstrap ${aws_instance.gitlab-ce.private_ip}",
    ]
  }
}

output "address" {
  value = "${aws_instance.gitlab-ce.private_ip}"
}

output "initial_root_password" {
  value = "${data.template_file.gitlab.vars.initial_root_password}"
}

output "runner_token" {
  value = "${data.template_file.gitlab.vars.runner_token}"
}

# vim: sw=4 ts=4

