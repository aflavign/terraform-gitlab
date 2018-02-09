# get remote state to retreive id used for all accounts ressources
data "terraform_remote_state" "infra" {
  backend = "s3"

  config {
    bucket = "bucket-name"
    key    = "key.tfstate"
    region = "region

  }
}
