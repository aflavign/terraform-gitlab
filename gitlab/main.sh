#/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Missing param"
  echo "host key name"
  exit 1
fi

terraform init 

terraform plan -var host_key_name=$1
terraform apply -var host_key_name=$1
