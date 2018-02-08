#/bin/bash

if [ "$#" -ne 2  ]; then
  echo "Missing param"
  echo "host key name /gitlab_ip/ runner token"
  exit 1
fi


terraform init -backend-config="bucket=yxdzlwvolxmz-eu-central-1-tfstate-infra"\
               -backend-config="key=gitlab/runner.tfstate"\
               -backend=true -force-copy -get=true -input=false

terraform destroy -var gitlab-ce_private_ip=$1 -var runner_token=$2
