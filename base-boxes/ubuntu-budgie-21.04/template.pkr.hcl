# Vagrant Base Box build
# Follows Vagrant Base Box requirements and guidelines
# https://www.vagrantup.com/docs/boxes/base.html

variable "timezone" {
  default = "US/Central"
}

variable "os" {
  default = "Ubuntu"
}

variable "os-variant" {
  default = "Budgie"
}

variable "os-bits" {
  default = "64"
}

variable "os-version" {
  default = "21.04"
}

variable "os-patch-version" {
  default = "0"
}

variable "box-version" {
  default = "1.0.0"
}

variable "username" {
  default = "vagrant"
}

variable "password" {
  default = "vagrant"
}

variable "organization" {
  default = "jgriepentrog"
}

variable "headless" {
  default = false
}

locals {
  sudo-cmd = "echo '${var.password}' | sudo -S -E"
  iso-base-path = "http://cdimage.ubuntu.com/ubuntu-budgie/releases"
  os-full-name = "${lower(var.os)}${var.os-variant == "" ? "" : "-${lower(var.os-variant)}"}"
  os-full-version = "${var.os-version}${var.os-patch-version == "0" || var.os-patch-version == "" ? "" : ".${var.os-patch-version}"}"
  os-name-version = "${local.os-full-name}-${var.os-version}"
  iso-release-path = "${local.iso-base-path}/${local.os-full-version}/release"
  iso-name = "${local.os-full-name}-${local.os-full-version}-desktop-amd64.iso"
  vm-name = "${local.os-name-version}-${var.box-version}"
}

source "virtualbox-iso" "vbox" {
  ### VM Options ###
  disk_size = 40000
  guest_additions_mode = "disable"
  guest_os_type = "${var.os}${var.os-bits == "64" ? "_64" : ""}"
  hard_drive_discard = true
  hard_drive_interface = "sata"
  sata_port_count = 2
  hard_drive_nonrotational = true
  iso_interface = "sata"
  vm_name = local.vm-name
  cpus = 4
  memory = 8192
  vboxmanage = [
    [ "modifyvm", "{{.Name}}", "--acpi", "on" ],
    [ "modifyvm", "{{.Name}}", "--rtcuseutc", "on" ],
    [ "modifyvm", "{{.Name}}", "--apic", "on" ],
    [ "modifyvm", "{{.Name}}", "--pae", "on" ],
    [ "modifyvm", "{{.Name}}", "--hwvirtex", "on" ],
    [ "modifyvm", "{{.Name}}", "--nestedpaging", "on" ],
    [ "modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga" ],
    [ "modifyvm", "{{.Name}}", "--vram", "32" ],
    [ "modifyvm", "{{.Name}}", "--vrde", "off" ],
    [ "modifyvm", "{{.Name}}", "--nictype1", "virtio" ],
    [ "storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove" ],
  ]
  ### ISO Options ###
  iso_url = "${local.iso-release-path}/${local.iso-name}"
  iso_checksum = "file:${local.iso-release-path}/SHA256SUMS"
  ### HTTP Server Options ###
  http_directory = "base-boxes/_common/${lower(var.os)}/http"
  ### Export Options ###
  format = "ovf"
  ### Run Options ###
  headless = "${var.headless}"
  ### Shutdown Options ###
  shutdown_command = "${local.sudo-cmd} shutdown -P now"
  ### Communicator Options ###
  communicator = "ssh"
  ssh_username = "${var.username}"
  ssh_password = "${var.password}"
  ssh_timeout = "90m"
  #pause_before_connecting = "10m"
  ### Boot Options ###
  boot_wait = "7s"
  # References for boot command and preseed options
  # https://wiki.ubuntu.com/UbiquityAutomation
  # https://wiki.ubuntu.com/Enterprise/WorkstationAutoinstallPreseed
  boot_command = [
    "<esc><wait>",
    "<esc><wait>",
    "<esc><wait>",
    "<enter>",
    ## Boot into Casper ##
    "/casper/vmlinuz<wait>",
    " boot=casper",
    " initrd=/casper/initrd",
    ## Get an IP from DHCP ##
    " ip=dhcp",
    ## Automatic install ##
    " auto",
    " noprompt",
    " automatic-ubiquity",
    ## Set up clock/timezone ##
    " time/zone=${var.timezone}",
    ## Set up user ##
    " passwd/root-login=true", # Per base box requirements
    " passwd/root-password=${var.password}", # Per base box requirements
    " passwd/root-password-again=${var.password}", # Per base box requirements
    " user-setup/allow-password-weak=true", # Default Vagrant password is weak
    " passwd/user-fullname=${var.username}", 
    " passwd/username=${var.username}",
    " passwd/user-password=${var.password}", 
    " passwd/user-password-again=${var.password}",
    " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
    " --- <wait>",
    "<enter><wait>"
  ]
}

# A build starts sources and runs provisioning steps on those sources.
build {
  sources = [
    "source.virtualbox-iso.vbox"
  ]

  provisioner "shell-local" {
    inline = [
      "vagrant cloud box create ${var.organization}/${local.os-name-version} --description '${var.os} ${var.os-variant == "" ? "" : "${var.os-variant} "}${local.os-full-version} Minimal Base Box'"
    ]
    valid_exit_codes = [0,1] # Error code is 1 if box already exists
  }

  # Get latest packages, install a few common dependencies (e.g. build-essential), and clean up unused ones
  provisioner "shell" {
    execute_command = "${local.sudo-cmd} bash '{{ .Path }}'"
    scripts = [
      "base-boxes/_common/ubuntu/updateInstallPkgs.sh"
    ]
  }

  # Install Virtualbox guest additions
  provisioner "shell" {
    execute_command = "${local.sudo-cmd} bash '{{ .Path }}'"
    scripts = [
      "base-boxes/_common/virtualbox/virtualbox-guest-additions-install.sh"
    ]
    only = [
      "virtualbox-iso"
    ]
  }

  # Set up VM to meet Vagrant base box requirements
  provisioner "shell" {
    execute_command = "${local.sudo-cmd} bash '{{ .Path }}'"
    scripts = [
      "base-boxes/_common/vagrant/vagrant.sh"
    ]
  }

  # Build the Vagrant base box
  post-processor "vagrant" {
    compression_level = 9
    output = "${local.vm-name}.box"
    vagrantfile_template = "base-boxes/_common/vagrant/Vagrantfile.template"
  }

  post-processor "vagrant-cloud" {
    #keep_input_artifact = false
    box_tag = "${var.organization}/${local.os-name-version}"
    version = var.box-version
    version_description = "See CHANGELOG at https://github.com/jgriepentrog/packer-templates"
  }
}
