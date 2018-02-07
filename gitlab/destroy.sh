#/bin/bash

set -x

if [ "$#" -ne 1 ]; then
  echo "Missing param"
  echo "host key name"
  exit 1
fi

terraform init 

terraform destroy -var host_key_name=$1
