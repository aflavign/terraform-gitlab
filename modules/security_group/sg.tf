resource "aws_security_group" "gitlab_host_SG" {
  name        = "${var.name}"
  description = "Rules for Gitlab host access"
  vpc_id      = "${var.vpc_id}"

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

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "id" {
  value = "${aws_security_group.gitlab_host_SG.id}"
}
