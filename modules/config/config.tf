# get remote state to retreive id used for all accounts ressources
data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "yxdzlwvolxmz-eu-central-1-tfstate-infra"
    key    = "landing-zone/infra/infra.tfstate"
    region = "eu-central-1"
  }
}
