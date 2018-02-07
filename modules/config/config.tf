# get remote state to retreive id used for all accounts ressources
data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "yxdzlwvolxmz-eu-central-1-tfstate-infra"
    key    = "landing-zone/infra/infra.tfstate"
    region = "eu-central-1"
  }
}

output "vpc_id" {
  value = "${data.terraform_remote_state.infra.vpc_id}"
}

output "public_subnet_a_id" {
  value = "${data.terraform_remote_state.infra.public_subnet_a_id}"
}
