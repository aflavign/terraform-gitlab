provider "google" {
    credentials = "${file("${var.auth_file}")}"
    project = "${var.project}"
    region = "${var.region}"
}

resource "google_compute_disk" "data_volume" {
    count = "${var.data_volume != "default" ? 1 : 0}"
    name = "${var.data_volume}"
    type = "${var.data_volume_type}"
    zone = "${var.zone}"
    size = "${var.data_size}"
}

resource "google_compute_network" "gitlab_network" {
    count = "${var.network != "default" ? 1 : 0}"
    description = "Network for GitLab instance"
    name = "${var.network}"
    auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "external_ports" {
    name = "${var.external_ports_name}"
    network = "${var.network}"

    allow {
        protocol = "tcp"
        ports = "${var.public_ports}"
    }
}

resource "google_compute_address" "external_ip" {
    name = "gitlab-external-address"
    region = "${var.region}"
}

resource "google_compute_instance" "gitlab-ce" {
    name = "${var.instance_name}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"

    tags = ["gitlab"]

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

    provisioner "file" {
        source = "${var.config_file}"
        destination = "/etc/gitlab/gitlab.rb"
        connection {
            type = "ssh"
            user = "root"
            agent = "true"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "mount /dev/disk/by-id/gitlab_data /var/opt/gitlab/",
            "apt-get install curl openssh-server ca-certificates postfix",
            "curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash",
            "apt-get install -y gitlab-ce",
            "/opt/gitlab/bin/gitlab-ctl reconfigure"
        ]

        connection {
            type = "ssh"
            user = "root"
            agent = "false"
        }
    }
}

resource "google_dns_record_set" "gitlab_instance" {
    name = "${var.dns_name}"
    type = "A"
    ttl = 300
    # TODO: This is really hard to read. I'd like to revisit at some point to clean it up.
    # But we shouldn't need two variables to specify DNS name
    managed_zone = "${join(".", slice(split(".", var.dns_name), 1, length(split(".", var.dns_name))))}"
    rrdatas = ["${google_compute_instance.gitlab-ce.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "address" {
    value = "${google_compute_instance.gitlab-ce.network_interface.0.access_config.0.assigned_nat_ip}"
}
# vim: sw=4 ts=4
