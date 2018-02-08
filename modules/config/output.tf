output "vpc_id" {
  value = "${data.terraform_remote_state.infra.vpc_id}"
}

output "public_subnet_a_id" {
  value = "${data.terraform_remote_state.infra.public_subnet_a_id}"
}
