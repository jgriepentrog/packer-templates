#!/bin/bash
set -o pipefail

### Vars / Setup ###

# App Versions
terraformVersion="0.12.29"
nodeVersion="12" # Match current AWS Lambda (generally LTS)

# Apt Package Lists
aptPkgRemovals="firefox plank libreoffice*"
aptPkgInstalls="net-tools whois \
								build-essential \
								nodejs python3-gpg python3-pip ruby \
								lightdm-settings arc-theme \
								gedit gthumb \
								google-chrome-stable keepass2 \
								keychain git \
								docker-ce docker-ce-cli containerd.io \
								adb"

# Snap Package Lists
snapPackageListModern="canonical-livepatch postman"
snapPackageListClassic="code"
#snapPackageListCustom1="node --classic --channel=$nodeVersion"

# Pip Package Lists
pipPackageList="aws-sam-cli"

### Package Installs ###

## Add Repos ##

# Git #
sudo add-apt-repository ppa:git-core/ppa

#Chrome - Official#
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

#Docker#
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list

#NodeJS#
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
echo "deb [arch=amd64] https://deb.nodesource.com/node_$nodeVersion.x focal main" | sudo tee /etc/apt/sources.list.d/nodesource.list
echo "deb-src [arch=amd64] https://deb.nodesource.com/node_$nodeVersion.x focal main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
   
# Update package list to latest
sudo apt-get update

## Packages Removals ##
# Remove unneeded / unused / outdated items
sudo apt-get -y remove $aptPkgRemovals
sudo apt-get -y autoremove

## Package Upgrades ##
sudo apt-get upgrade -y

## Repo Package Installs ##
# Apt
sudo apt-get install -y $aptPkgInstalls

# Snaps
sudo snap install $snapPackageListModern
sudo snap install $snapPackageListClassic --classic
#sudo snap install $snapPackageListCustom1

# pip
python3 -m pip install --upgrade pip setuptools
pip3 install --upgrade $pipPackageList

## Non-Repo Package Installs
# Terraform
terraformZipName="terraform_${terraformVersion}_linux_amd64.zip"
wget -q https://releases.hashicorp.com/terraform/$terraformVersion/$terraformZipName
unzip $terraformZipName
sudo mv terraform /usr/local/bin
rm -f $terraformZipName
 
# AWS CLI
awsCliUrl="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
awsCliFile="awscliv2.zip"
curl $awsCliUrl -o $awsCliFile
unzip $awsCliFile
sudo ./aws/install

# Postman
#POSTMAN_FILE="postman.tar.gz"
#wget -q https://dl.pstmn.io/download/latest/linux64 -O $POSTMAN_FILE
#sudo tar -xzf $POSTMAN_FILE -C /opt
#rm -f $POSTMAN_FILE
#sudo ln -s /opt/Postman/Postman /usr/bin/postman

### Global Package Setups / Config ###
# NPM
#Increases max watches which is needed for dealing with large # of files in a directory
#Can be common for large NPM dependencies trees
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
#Upgrade to latest
sudo npm install npm@latest -g

# ADB
sudo touch /etc/udev/rules.d/51-android.rules
echo 'SUBSYSTEM==\"usb\", ATTR{idVendor}==\"2e17\", MODE=\"0666\", GROUP=\"plugdev\"' | sudo tee -a /etc/udev/rules.d/51-android.rules	

# Login Screen - Slick Greeter / LightDM
LOGIN_BG_FILE="login_bg.jpg"
wget -q "https://drive.google.com/uc?id=11XqcESHcqHzZ35DJLVUj8XebbJ6KcD6I&export=download" -O $LOGIN_BG_FILE
sudo cp $LOGIN_BG_FILE /usr/share/backgrounds/$LOGIN_BG_FILE
rm -f $LOGIN_BG_FILE
sudo cp settings/lightdm/slick-greeter.conf /etc/lightdm

### Clean Up ###
# Clean up any uneeded packages and downloads
sudo apt-get -y autoremove
sudo apt-get -y clean

### Verify Apps Availability ###
echo ""
echo "=== Software Versions ==="
echo Node: `node -v`
echo NPM: `npm -v`
echo AWS: `aws --version`
echo SAM: `sam --version`
echo VSCode: `code -v --user-data-dir /dev/null | grep ^[0-9]*\\.[0-9]*\\.[0-9]*$`
echo Docker: `docker -v`
echo git: `git --version`
echo adb: `adb --version`
echo "========================="
