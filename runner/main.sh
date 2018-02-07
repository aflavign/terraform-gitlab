#/bin/bash

if [ "$#" -ne 3  ]; then
  echo "Missing param"
  echo "host key name /gitlab_ip/ runner token"
  exit 1
fi

terraform init 

terraform plan -var host_key_name=$1 -var gitlab-ce_private_ip=$2 -var runner_token=$3
terraform apply -var host_key_name=$1 -var gitlab-ce_private_ip=$2 -var runner_token=$3
