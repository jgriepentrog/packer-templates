#!/bin/bash
set -o pipefail

#Update package list to latest
sudo apt-get update

#Install packages
sudo snap install remmina
sudo snap connect remmina:avahi-observe :avahi-observe
sudo snap connect remmina:cups-control :cups-control
sudo snap connect remmina:mount-observe :mount-observe
sudo snap connect remmina:password-manager-service :password-manager-service

sudo apt-get install -y openvpn
sudo apt-get install -y network-manager-openvpn
sudo apt-get install -y network-manager-openvpn-gnome

sudo service network-manager restart

#Install EasyTether
easyTetherVersion="0.8.9"
easyTetherFileName="easytether_${easyTetherVersion}_amd64.deb"
wget http://www.mobile-stream.com/beta/ubuntu/18.04/$easyTetherFileName
sudo dpkg -i $easyTetherFileName
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd