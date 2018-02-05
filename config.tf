variable "image" {
  description = "The image to use for the instance"
  default     = "ubuntu-1604-xenial-v20170330"
}

variable "machine_type" {
  description = "A machine type for your compute instance"
  default     = "t2.small"
}

variable "network" {
  description = "The network for the instance to live on"
  default     = "default"
}

variable "public_ports_ssl" {
  description = "A list of ports that need to be opened for GitLab to work"
  default     = ["80", "443", "22"]
}

variable "public_ports_no_ssl" {
  description = "A list of ports that need to be opened for GitLab to work"
  default     = ["80", "22"]
}

variable "region" {
  description = "The region this all lives in. TODO can this be inferred from zone or vice versa?"
  default     = "eu-central-1"
}

variable "external_ports_name" {
  description = "The name of the external ports object, can be used to reuse lists"
  default     = "gitlab-external-ports"
}

variable "instance_name" {
  description = "The name of the instance to use"
  default     = "gitlab-instance"
}

variable "config_file" {
  description = "Configuration file to use for /etc/gitlab/gitlab.rb"
}

variable "ssh_key" {
  description = "The ssh key to use to connect to the Google Cloud Instance"
  default     = "~/.ssh/id_rsa"
}

variable "deploy_gitlab" {
  description = "Enable / Disable deploying a GitLab instance"
  default     = true
}

variable "initial_root_password" {
  description = "Set the initial admin password, generated if not provided"
  default     = "GENERATE"
}

variable "prefix" {
  description = "Prefix to resource names in cloud provider"
}

variable "runner_count" {
  description = "Number of GitLab CI Runners to create."
  default     = 1
}

variable "runner_host" {
  description = "URL of the GitLab server Runner will register with"
  default     = "GENERATE"
}

variable "runner_token" {
  description = "GitLab CI Runner registration token. Will be generated if not provided"
  default     = "GENERATE"
}

variable "runner_disk_size" {
  description = "Size of disk (in GB) for Runner instances"
  default     = 20
}

variable "runner_image" {
  description = "The Docker image a GitLab CI Runner will use by default"
  default     = "ruby:2.3"
}

variable "runner_machine_type" {
  description = "A machine type for your compute instance, used by GitLab CI Runner"
  default     = "t2.small"
}

variable "tag_Owner" {
  description = "An Owner"
  default     = "CloudFoundation"
}

variable "host_key_name" {
  description = "Key Pair"
}
