variable "os" {
  default = "ubuntu-budgie"
}

variable "os-version" {
  default = "20.04"
}

variable "name" {
  default = "TuxDev"
}

locals {
  shared_path = "personal-boxes"
  common_path = "${local.shared_path}/_common"
  path = "${local.shared_path}/${var.os}-dev-${var.os-version}"
  provisioning_dir = "/home/vagrant/"
  sudo_cmd = "sudo -S -E"
}

source "vagrant" "vagrant" {
  communicator = "ssh"
  source_path = "jgriepentrog/${var.os}-${var.os-version}"
  box_name = "${lower(var.name)}-${var.os}-${var.os-version}"
  provider = "virtualbox"
  teardown_method = "destroy"
  output_vagrantfile = "${local.path}/Vagrantfile.template"
  package_include = [
    "${local.common_path}/personalize.sh",
    "${local.common_path}/docker.sh",
    "${local.common_path}/runas.sh",
    "${local.common_path}/unbase.sh",
    "${local.path}/config.sh"
  ]
}

# A build starts sources and runs provisioning steps on those sources.
build {
  sources = [
    "source.vagrant.vagrant"
  ]

  provisioner "shell" {
    inline = [
      "mkdir -p ${local.provisioning_dir}"
    ]
  }

  provisioner "file" {
    source = "${local.path}/"
    destination = local.provisioning_dir
  }

  # Install personal image packages and complete configuration
  provisioner "shell" {
    execute_command = "${local.sudo_cmd} bash '{{ .Path }}'"
    scripts = [
      "${local.path}/build.sh"
    ]
  }

  # Allow root ssh login
  provisioner "shell" {
    inline = [
      "echo 'PermitRootLogin yes' | ${local.sudo_cmd} tee -a /etc/ssh/sshd_config"
    ]
  }

  #post-processor "vagrant-cloud" {
  #  box_tag = "jgriepentrog/tuxdev"
  #  version = "${var.os}-${var.os-version}"
  #  keep_input_artifact = false
  #  version_description = "Personal Ubuntu Budgie ${var.ubuntu-version}"
  #}
}
