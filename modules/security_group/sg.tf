resource "aws_security_group" "gitlab_sg" {
  name        = "${var.name}"
  description = "Rules for Gitlab host access"
  vpc_id      = "${var.vpc_id}"

  # All access from VPC and this SG
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_blocks}"]
    self        = true
  }

  # HTTP access from Public ips and this SG
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  # SSH access from Public ips and this SG
  ingress {
    from_port   = 22
    to_port     = 22
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

  tags {
    Name = "sgr.${var.region}.${var.name}"
  }
}

output "id" {
  value = "${aws_security_group.gitlab_sg.id}"
}
