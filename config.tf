variable "auth_file" {
    description = "The configuration file containing the credentials to connect to google"
}

variable "data_size" {
    description = "The size of the data volume to create in gigabytes"
    default = "10"
}

variable "data_volume" {
    description = "A storage volume for storing your GitLab data"
    default = "default"
}

variable "image" {
    description = "The image to use for the instance"
    default = "ubuntu-1604-xenial-v20170330"
}

variable "machine_type" {
    description = "A machine type for your compute instance"
    default = "n1-standard-1"
}

variable "network" {
    description = "The network for the instance to live on"
    default = "default"
}

variable "public_ports_ssl" {
    description = "A list of ports that need to be opened for GitLab to work"
    default = ["80", "443", "22"]
}

variable "public_ports_no_ssl" {
    description = "A list of ports that need to be opened for GitLab to work"
    default = ["80", "22"]
}

variable "region" {
    description = "The region this all lives in. TODO can this be inferred from zone or vice versa?"
    default = "us-central1"
}

variable "zone" {
    description = "The zone to deploy the machine to"
    default = "us-central1-a"
}

variable "data_volume_type" {
    description = "The type of volume to use for data"
    default = "pd-standard"
}

variable "external_ports_name" {
    description = "The name of the external ports object, can be used to reuse lists"
    default =  "gitlab-external-ports"
}

variable "instance_name" {
    description = "The name of the instance to use"
    default = "gitlab-instance"
}

variable "config_file" {
    description = "Configuration file to use for /etc/gitlab/gitlab.rb"
}

variable "dns_name" {
    description = "The dns name of the instance to launch. Assumes the zone is part of the google managed zones"
    default = "no_dns"
}

variable "dns_zone" {
    description = "The name of the DNS zone in Google Cloud that the DNS name should go under"
    default = "no_dns"
}

variable "project" {
    description = "The project in Google Cloud to create the GitLab instance under"
}

variable "ssh_key" {
    description = "The ssh key to use to connect to the Google Cloud Instance"
    default = "~/.ssh/id_rsa"
}

variable "ssl_key" {
    description = "The SSL keyfile to use"
    default = "/dev/null"
}

variable "ssl_certificate" {
    description = "The SSL certificate file to use"
    default = "/dev/null"
}
