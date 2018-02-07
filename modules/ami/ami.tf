data "aws_ami" "rhel7" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*RHEL-7.4*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # Canonical
}

output "id" {
  value = "${data.aws_ami.rhel7.id}"
}
