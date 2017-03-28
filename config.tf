variable "config_file" {
    description = "The configuration file containing the credentials to connect to google"
    default = "config.json"
}

variable "data_size" {
    description = "The size of the data volume to create in gigabytes"
    default = "10"
}

variable "data_volume" {
    description = "A storage volume for storing your GitLab data"
}

variable "image" {
    description = "The image to use for the instance"
    default = "packer-1489607951"
}

variable "machine_type" {
    description = "A machine type for your compute instance"
    default = "n1-standard-1"
}

variable "network" {
    description = "The network for the instance to live on"
    default = "default"
}

variable "public_ports" {
    description = "A list of ports that need to be opened for GitLab to work"
    default = ["80", "443", "22"]
}

variable "region" {
    description = "The region this all lives in. TODO can this be inferred from zone or vice versa?"
}

variable "zone" {
    description = "The zone to deploy the machine to"
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
