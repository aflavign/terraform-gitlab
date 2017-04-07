A terraform configuration to spin up a GitLab instance using the Google Compute engine

To use, create a config like:
```
module "mygitlab" {
  source = "https://gitlab.com/gitlab-terraform/gce"
  data_volume = "$volume"
  network = "$network"
  project = "$project"
  region = "$region"
  zone = "$zone"
}
```

Options:
  * required:
    * config_file -- This should be your gitlab.rb file you want to use to configure your GitLab instance. At the very least, external_url should be set.
    * data_volume -- The name of the data volume to use to store the GitLab data on.
    * dns_name -- What the DNS name for the GitLab instance should be. This is assumed to be part of a Google Cloud DNS Zone.
    * project -- Which Google Cloud project the resources should be created under.
  * not required:
    * auth_file (Default: config.json) -- The file containing the authentication details for your Google Cloud Service Account [See the Terraform documenation](https://www.terraform.io/docs/providers/google/index.html) for details on how to generate this file.
    * data_size (Default: 10gb) -- If creating a data volume for you, how large should it be.
    * image (Default: ubuntu-1604-xenial-v20170330) -- Which base image we should use. Currently other portions assume this is a Debian based system. We may remove this variable in the future.
    * machine_type (Default: n1-standard-1) -- The machine type to use
    * network (Default: default) -- The network to put the instance on.
    * public_ports (Default: 22, 80, 443) -- Which ports on the firewall should be open to the world.
    * region (Default: us-central1) -- Which region to allocate the reources in.
    * zone (Default: us-central-1-a) -- Which specific zone to allocate the resources in.
