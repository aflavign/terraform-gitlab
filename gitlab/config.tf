variable "machine_type" {
  description = "A machine type for your compute instance"
  default     = "t2.large"
}

variable "network" {
  description = "The network for the instance to live on"
  default     = "default"
}

variable "region" {
  description = "The region this all lives in. TODO can this be inferred from zone or vice versa?"
  default     = "eu-central-1"
}

variable "instance_name" {
  description = "The name of the instance to use"
  default     = "gitlab-instance"
}

variable "deploy_gitlab" {
  description = "Enable / Disable deploying a GitLab instance"
  default     = true
}

variable "tag_Owner" {
  description = "An Owner"
  default     = "CloudFoundation"
}

variable "host_key_name" {
  description = "Key Pair"
}

