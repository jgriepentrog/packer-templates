#!/bin/bash
set -o pipefail
export OS="ubuntu-budgie"
export OS_VER="20.04"

if [ -z $VAGRANT_CLOUD_TOKEN ]; then 
  echo "Need to set VAGRANT_CLOUD_TOKEN"
  exit -1
fi

packer build base-boxes/${OS}-${OS_VER}/template.pkr.hcl