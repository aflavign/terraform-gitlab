provider "google" {
    credentials = "${file("${var.auth_file}")}"
    project = "${var.project}"
    region = "${var.region}"
}

resource "google_compute_network" "gitlab_network" {
    count = "${var.network != "default" ? 1 : 0}"
    description = "Network for GitLab instance"
    name = "${var.network}"
    auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "external_ports_ssl" {
    count = "${var.ssl_certificate != "/dev/null" ? var.deploy_gitlab ? 1 : 0 : 0}"
    name = "${var.prefix}${var.external_ports_name}"
    network = "${var.network}"

    allow {
        protocol = "tcp"
        ports = "${var.public_ports_ssl}"
    }
}

resource "google_compute_firewall" "external_ports_no_ssl" {
    count = "${var.ssl_certificate != "/dev/null" ? 0 : var.deploy_gitlab ? 1 : 0}"
    name = "${var.prefix}${var.external_ports_name}"
    network = "${var.network}"

    allow {
        protocol = "tcp"
        ports = "${var.public_ports_no_ssl}"
    }
}

resource "google_compute_address" "external_ip" {
    count = "${var.deploy_gitlab ? 1 : 0}"
    name = "${var.prefix}gitlab-external-address"
    region = "${var.region}"
}

resource "random_id" "initial_root_password" {
    byte_length = 15
}

resource "random_id" "runner_token" {
    byte_length = 15
}

data "template_file" "gitlab" {
    template = "${file("${path.module}/templates/gitlab.rb.append")}"

    vars {
        initial_root_password = "${var.initial_root_password != "GENERATE" ? var.initial_root_password : random_id.initial_root_password.hex}"
        runner_token = "${var.runner_token != "GENERATE" ? var.runner_token : random_id.runner_token.hex}"
    }
}

resource "google_compute_instance" "gitlab-ce" {
    count = "${var.deploy_gitlab ? 1 : 0}"
    name = "${var.prefix}${var.instance_name}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"

    tags = ["gitlab"]

    connection {
        type = "ssh"
        user = "ubuntu"
        agent = "false"
        private_key = "${file("${var.ssh_key}")}"
    }

    disk {
        image = "${var.image}"
    }

    disk {
        disk = "${var.data_volume}"
        auto_delete = "false"
        device_name = "gitlab_data"
    }

    network_interface {
        network = "${var.network}"
        access_config {
            nat_ip = "${google_compute_address.external_ip.address}"
        }
    }

    metadata {
        sshKeys = "ubuntu:${file("${var.ssh_key}.pub")}"
    }

    provisioner "file" {
        content = "${data.template_file.gitlab.rendered}"
        destination = "/tmp/gitlab.rb.append"
    }

    provisioner "file" {
        source = "${var.config_file}"
        destination = "/tmp/gitlab.rb"
    }

    provisioner "file" {
        source = "${path.module}/bootstrap"
        destination = "/tmp/bootstrap"
    }

    provisioner "file" {
        source = "${var.ssl_key}"
        destination = "/tmp/ssl_key"
    }

    provisioner "file" {
        source = "${var.ssl_certificate}"
        destination = "/tmp/ssl_certificate"
    }

    provisioner "remote-exec" {
        inline = [
            "cat /tmp/gitlab.rb.append >> /tmp/gitlab.rb",
            "chmod +x /tmp/bootstrap",
            "sudo /tmp/bootstrap ${var.dns_name}"
        ]
    }
}

resource "google_dns_record_set" "gitlab_instance" {
    count = "${var.dns_zone != "no_dns" ? 1 : 0}"
    name = "${var.dns_name}."
    type = "A"
    ttl = 300
    # TODO: This is really hard to read. I'd like to revisit at some point to clean it up.
    # But we shouldn't need two variables to specify DNS name
    managed_zone = "${var.dns_zone}"
    rrdatas = ["${google_compute_instance.gitlab-ce.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "address" {
    value = "${google_compute_instance.gitlab-ce.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "initial_root_password" {
    value = "${data.template_file.gitlab.vars.initial_root_password}"
}

output "runner_token" {
    value = "${data.template_file.gitlab.vars.runner_token}"
}
# vim: sw=4 ts=4
