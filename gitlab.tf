provider "google" {
    credentials = "${file("${var.config_file}")}"
    region = "${var.region}"
}

resource "google_compute_disk" "data_volume" {
    name = "${var.data_volume}"
    type = "${var.data_volume_type}"
    zone = "${var.zone}"
    size = "${var.data_size}"
}

resource "google_compute_network" "gitlab_network" {
    description = "Network for GitLab instance"
    name = "${var.network}"
    auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "external_ports" {
    name = "${var.external_ports_name}"
    network = "${google_compute_network.gitlab_network.name}"

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
        network = "${google_compute_network.gitlab_network.self_link}"
        access_config {
            nat_ip = "${google_compute_address.external_ip.address}"
        }
    }
}

# vim: sw=4 ts=4
