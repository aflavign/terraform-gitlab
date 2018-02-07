#/bin/bash

if [ "$#" -ne 2  ]; then
  echo "Missing param"
  echo "gitlab_ip/ runner token"
  exit 1
fi

terraform init 

terraform plan -var gitlab-ce_private_ip=$1 -var runner_token=$2
terraform apply -var gitlab-ce_private_ip=$1 -var runner_token=$2
