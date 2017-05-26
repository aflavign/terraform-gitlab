A Terraform configuration to spin up a GitLab and/or GitLab Runner instance(s) using the Google Compute Engine on Google Cloud.

This project can be used to spin up:
* A GitLab instance
* A GitLab instance and GitLab Runner instance(s)
* GitLab Runner instance(s) attached to external GitLab servers.

By default, this will spin up a GitLab instance with one runner

## Usage
1. Install [Terraform](https://www.terraform.io/downloads.html)
1. Ensure your [ssh key is added](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys) to the Google Cloud Project your going to create the instance in.

#### Deploying GitLab, with or without GitLab Runner
1. [Create a persistent disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk) to store the repository and database on. Don't worry about attaching it to an instance, formatting or partitioning, Terraform will do that for you. Place the disk in the same zone that you are going to be allocating the instance in.
1. Create a terraform configuration file `gitlab.tf`, and supply option values:

  ```
  module "mygitlab" {
    source = "git::https://gitlab.com/gitlab-terraform/gce.git"
    auth_file = "path/to/key.json"
    project = "gcp_project_name"
    region = "gcp_region"
    zone = "gcp_zone"
    ...
    config_file = "path/to/gitlab.rb"
    data_volume = "data_voume_disk_name"
    dns_name = "your_hostname_here"
    ...
    runner_count = number_of_runners
  }
  ```

1. Run `terraform get`
1. Run `terraform plan`, ensure everything it's going to do looks correct.
1. Run `terraform apply`
1. Run `terraform output --module=mygitlab`
1. Go to: `http://$dns_name` login with the `initial_root_password`

#### Deploying GitLab Runner(s) to External GitLab services

Configuring Terraform to deploy GitLab Runner instance(s) against an external GitLab
service is slightly different. See below for an example configuration against https://gitlab.com
1. Create a terraform configuration file `gitlab.tf`, and supply option values:

  ```
  module "mygitlab" {
    source = "git::https://gitlab.com/gitlab-terraform/gce.git"
    auth_file = "path/to/key.json"
    project = "gcp_project_name"
    region = "gcp_region"
    zone = "gcp_zone"
    ...
    deploy_gitlab = false
    config_file = "/dev/null"
    dns_name = "gitlab.com"
    runner_count = number_of_runners
    runner_host = "https://gitlab.com"
    runner_token = "TOKEN_FROM_GITLAB"
  }
  ```

1. Run `terraform get`
1. Run `terraform plan`, ensure everything it's going to do looks correct.
1. Run `terraform apply`

### Upgrading GitLab

Since all your data is stored on the attached disk, the quickest way to deploy the latest version of GitLab is to recreate the instance:
```
$ terraform destroy
$ terraform apply
```
This will require about 10 minutes downtime of your GitLab instance while the instance is recreated, no data should be lost.

**Note**: The external IP address of your instance might change due to this process. If you are managing DNS yourself, you may need to update the A record.


### Upgrading the Terraform module
On occasion, we will make updates to our terraform module. By default, `terraform get` does not update if you already have a copy of the module. If you'd like to take advantage of a newer version of the module:
```
$ terraform get -update=true
$ terraform plan # this will show you what changes will need to be made to bring your deploy up to the latest configuration.
$ terraform apply
```

### Terraform Variables (Options)
Options:
  * required:
    * `auth_file` -- A json file containing the credentials to use to connect to Google Cloud. Please see the [Terraform instructions](https://www.terraform.io/docs/providers/google/index.html#authentication-json-file) for obtaining this file.
    * `config_file` -- This should be your [gitlab.rb](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template) file you want to use to configure your GitLab instance. At the very least, `external_url` should be set. While all options are available for you to set, it is *highly* recommended that you avoid changing any of the paths available in the configuration file.
    * `data_volume` -- The name of the data volume to use to store the GitLab data on.
    * `dns_name` -- What the DNS name for the GitLab instance should be. This can be any FQDN that resolves to your instance.
    * `project` -- Which Google Cloud project the resources should be created under.
  * not required:
    * `deploy_gitlab` (Default: `true`) -- Enable / disable deployment of GitLab as a part of Terraform. This can be used to deploy _only_ GitLab Runners into GCE.
    * `dns_zone` (Default: `none`) -- Which Google Cloud DNS zone the FQDN of the host is going to fall under. This should already exist. Leave this blank if you are using a different mechanism for handling DNS. If you are not using Google Cloud DNS, please create an A record in your DNS configuration that matches the value specified in `dns_name`.
    * `image` (Default: `ubuntu-1604-xenial-v20170330`) -- Which base image we should use. Currently other portions assume this is a Debian based system. We may remove this variable in the future.
    * `machine_type` (Default: `n1-standard-1`) -- The machine type to use. The default should be sufficient for up to 100 developers. Please see [our hardware requirements](https://docs.gitlab.com/ce/install/requirements.html#hardware-requirements) for sizing recommendations if you need a larger instance.
    * `network` (Default: `default`) -- The network to put the instance on.
    * `public_ports` (Default: `22, 80, 443`) -- Which ports on the firewall should be open to the world.
    * `region` (Default: `us-central1`) -- Which region to allocate the resources in. If you're unsure of this, it is recommended to pick a region geographically close to where you will be accessing from.
    * `ssh_key` (Default: `~/.ssh/id_rsa`) -- The ssh key to use to authenticate to the host.
    * `ssl_certificate` (Default: `none`) -- If you want to use SSL, create the SSL key and certificate files, and specify the path to the certificate here. Also ensure `external_url` in your GitLab config starts with `https`. Ensure `ssl_key` is set as well.
    * `ssl_key` (Default: `none`) -- The path to your SSL key file, if you're using SSL.
    * `zone` (Default: `us-central-1-a`) -- Which specific zone to allocate the resources in.
    * `initial_root_password` (Default: randomly generated) -- Value to set as the initial password for the `root` user account on the deployed GitLab instance.
    * `runner_token` (Default: randomly generated) -- Token that GitLab Runner instances will use to register against the `runner_host`.
    * `runner_host` (Default: generated from `dns_name`) -- URL of GitLab instance for GitLab Runner instances to register against. If not provided, it will generate from `dns_name` provided for the GitLab instance.
    * `runner_count` (Default: `1`) -- Number of GitLab Runners to create and attach to the GitLab instance either deployed, or reachable at `runner_host`.
    * `runner_machine_type` (Default: `n1-standard-1`) -- The machine type to use for GitLab Runner instances. Size according to your needs.
    * `runner_disk_size` (Default: `20`) -- Size of disk (in GB) to use for GitLab Runner instances.
    * `runner_image` (Default: `ruby:2.3`) -- The Docker image that should be used by default.
