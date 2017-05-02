A terraform configuration to spin up a GitLab instance using the Google Compute engine

## Usage
1. Install [Terraform](https://www.terraform.io/downloads.html)
1. Ensure your [ssh key is added](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys) to the Google Cloud Project your going to create the instance in
1. [Create a persistent disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk) to store the repository and database on. Don't worry about attaching it to an instance, formatting or partitioning, Terraform will do that for you. Place the disk in the same zone that you are going to be allocating the instance in.
1. Create a terraform configuration file `gitlab.tf`:
```
module "mygitlab" {
  source = "git::https://gitlab.com/gitlab-terraform/gce.git"
  auth_file = "$auth_file"
  config_file = "$config_file"
  data_volume = "$volume"
  dns_name = "$dns_name"
  project = "$project"
  region = "$region"
  ...
  zone = "$zone"
}
```
1. Run `terraform get`
1. Run `terraform plan`, ensure everything it's going to do looks correct.
1. Run `terraform apply`
1. Go to: `http://$dns_name` and set your root password

Options:
  * required:
    * auth_file -- A json file containing the credentials to use to connect to Google Cloud. Please see the [Terraform instructions](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) for obtaining this file.
    * config_file -- This should be your [gitlab.rb](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template) file you want to use to configure your GitLab instance. At the very least, `external_url` should be set. While all options are available for you to set, it is *highly* recommended that you avoid changing any of the paths available in the configuration file.
    * data_volume -- The name of the data volume to use to store the GitLab data on.
    * dns_name -- What the DNS name for the GitLab instance should be. This is assumed to be part of a Google Cloud DNS Zone.
    * project -- Which Google Cloud project the resources should be created under.
  * not required:
    * auth_file (Default: config.json) -- The file containing the authentication details for your Google Cloud Service Account [See the Terraform documenation](https://www.terraform.io/docs/providers/google/index.html) for details on how to generate this file.
    * dns_zone (Default: none) -- Which Google Cloud DNS zone the FQDN of the host is going to fall under. This should already exist. Leave this blank if you are using a different mechanism for handling DNS. If you are not using Google Cloud DNS, please create an A record in your DNS configuration that matches the value specified in `dns_name`.
    * image (Default: ubuntu-1604-xenial-v20170330) -- Which base image we should use. Currently other portions assume this is a Debian based system. We may remove this variable in the future.
    * machine_type (Default: n1-standard-1) -- The machine type to use. The default should be sufficient for up to 100 developers. Please see [our hardware requirements](https://docs.gitlab.com/ce/install/requirements.html#hardware-requirements) for sizing recommendations if you need a larger instance.
    * network (Default: default) -- The network to put the instance on.
    * public_ports (Default: 22, 80, 443) -- Which ports on the firewall should be open to the world.
    * region (Default: us-central1) -- Which region to allocate the resources in. If you're unsure of this, it is recommended to pick a region geographically close to where you will be accessing from.
    * ssh_key (Default: ~/.ssh/id_rsa) -- The ssh key to use to authenticate to the host.
    * ssl_certificate (Default: none) -- If you want to use SSL, create the SSL key and certificate files, and specify the path to the certificate here. Also ensure `external_url` in your GitLab config starts with `https`. Ensure `ssl_key` is set as well.
    * ssl_key (Default: none) -- The path to your SSL key file, if you're using SSL.
    * zone (Default: us-central-1-a) -- Which specific zone to allocate the resources in.
