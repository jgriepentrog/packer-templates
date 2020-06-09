$OS="ubuntu-budgie"
$OS_VER="20.04"

if ($Env:VAGRANT_CLOUD_TOKEN -eq $null) {
  throw "Need to set VAGRANT_CLOUD_TOKEN"
}

packer build personal-boxes/$($OS)-dev-$($OS_VER)/template.pkr.hcl