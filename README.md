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
  required:
    data_volume
    network
    project
    region
    zone
  not required:
    config_file
    data_size
    image
    machine_type
    public_ports
