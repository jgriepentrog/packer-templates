# Vagrant Base Box build
# Follows Vagrant Base Box requirements and guidelines
# https://www.vagrantup.com/docs/boxes/base.html

variable "timezone" {
  default = "US/Central"
}

variable "ubuntu-version" {
  default = "20.04"
}


locals {
  # User/name password per Base Box reqs
  username = "vagrant"
  password = "vagrant"
  # Headless install; set false when troubleshooting
  headless = false
  sudo_cmd = "echo '${local.password}' | sudo -S -E"
}

source "virtualbox-iso" "vbox" {
  ### VM Options ###
  disk_size = 40000
  guest_additions_mode = "disable"
  guest_os_type = "Ubuntu_64"
  hard_drive_discard = true
  hard_drive_interface = "sata"
  sata_port_count = 2
  hard_drive_nonrotational = true
  iso_interface = "sata"
  vm_name = "UbuntuBudgie-${var.ubuntu-version}"
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
    [ "storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove" ],
  ]
  ### ISO Options ###
  iso_url = "http://cdimage.ubuntu.com/ubuntu-budgie/releases/${var.ubuntu-version}/release/ubuntu-budgie-${var.ubuntu-version}-desktop-amd64.iso"
  iso_checksum_type = "sha256"
  iso_checksum_url = "http://cdimage.ubuntu.com/ubuntu-budgie/releases/${var.ubuntu-version}/release/SHA256SUMS"
  ### HTTP Server Options ###
  http_directory = "base-boxes/_common/ubuntu/http"
  ### Export Options ###
  format = "ovf"
  ### Run Options ###
  headless = "${local.headless}"
  ### Shutdown Options ###
  shutdown_command = "${local.sudo_cmd} shutdown -P now"
  ### Communicator Options ###
  communicator = "ssh"
  ssh_username = "${local.username}"
  ssh_password = "${local.password}"
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
    " passwd/root-password=${local.password}", # Per base box requirements
    " passwd/root-password-again=${local.password}", # Per base box requirements
    " user-setup/allow-password-weak=true", # Default Vagrant password is weak
    " passwd/user-fullname=${local.username}", 
    " passwd/username=${local.username}",
    " passwd/user-password=${local.password}", 
    " passwd/user-password-again=${local.password}",
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

  # Get latest packages and clean up unused ones
  provisioner "shell" {
    execute_command = "${local.sudo_cmd} bash '{{ .Path }}'"
    scripts = [
      "base-boxes/_common/ubuntu/updatePkgs.sh"
    ]
  }

  # Install Virtualbox guest additions
  provisioner "shell" {
    execute_command = "${local.sudo_cmd} bash '{{ .Path }}'"
    scripts = [
      "base-boxes/_common/virtualbox/virtualbox-guest-additions-install.sh"
    ]
    ##!## Pending Packer HCL2 support - https://github.com/hashicorp/packer/issues/9094 ##!##
    #only = [
    #  "virtualbox-iso"
    #]
  }

  # Set up VM to meet Vagrant base box requirements
  provisioner "shell" {
    execute_command = "${local.sudo_cmd} bash '{{ .Path }}'"
    scripts = [
      "base-boxes/_common/vagrant/vagrant.sh"
    ]
  }

  # Build the Vagrant base box
  post-processor "vagrant" {
    compression_level = 9
    output = "UbuntuBudgie-${var.ubuntu-version}.box"
    vagrantfile_template = "base-boxes/_common/vagrant/Vagrantfile.template"
  }

  post-processor "vagrant-cloud" {
    box_tag = "jgriepentrog/ubuntu-budgie"
    version = var.ubuntu-version
  }
}
