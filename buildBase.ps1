$OS="ubuntu-budgie"
$OS_VER="21.04"

if ($Env:VAGRANT_CLOUD_TOKEN -eq $null) {
  throw "Need to set VAGRANT_CLOUD_TOKEN"
}

packer build base-boxes/$($OS)-$($OS_VER)/template.pkr.hcl