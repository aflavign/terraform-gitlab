#/bin/bash


terraform init -backend-config="bucket=yxdzlwvolxmz-eu-central-1-tfstate-infra"\
               -backend-config="key=gitlab/gitlab.tfstate"\
               -backend=true -force-copy -get=true -input=false 

terraform plan 
terraform apply
