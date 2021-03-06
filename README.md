A Terraform configuration to spin up a GitLab and/or GitLab Runner instance(s) in AWS 

This project can be used to spin up:
* A GitLab instance
* A GitLab instance and GitLab Runner instance(s)

## Usage
1. Install [Terraform](https://www.terraform.io/downloads.html)
1. Export AWS_ACCESS_KEY_ID/ AWS_SECRET_ACCESS_KEY

#### Deploying GitLab 

1. Go to folder `gitlab_host` 
1. Run `main.sh` which is running terraform scripts
1. Go to: `http://<address>` and set up a new password. <address> is available as output of terraform

#### Deploying GitLab Runner

1. Go to folder `gitlab_runner`
1. Run `main.sh $gitlab_host_address $shared_runner_token`(See below how to retrieve this token)
1. The runner is registered with Gitlab, allowing to execute CI/CD Pipelines 

#### Destroy GitLab Runner

1. Go to folder `gitlab_runner`
1. Run `destroy.sh`

#### Destroy GitLab 

1. Go to folder `gitlab_host`
1. Run `destroy.sh` 


#### Where to find Shared runner token
1. Access Gitlab Console at `http://<address>` and login as root
1. Go to: `http://<address>/admin/runners`
1. Token is displayed under "How to setup a specific runner` 

#### Retrieve Gitlab address
1. Go to folder `gitlab_host` 
1. Run: `terraform output address` 
