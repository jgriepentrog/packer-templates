#!/bin/bash
set -o pipefail

### Set Up ###

# Variables from input
SHARING_LINK=$1
SHARING_PASSWORD=$2

# Basic Info
username=`whoami`

# Git Info
email="1390583+jgriepentrog@users.noreply.github.com"
name="John Griepentrog"

# Directory
DIR=`echo ~`

### Package Config ###

# Postman Desktop Icon
#cat > ~/.local/share/applications/postman.desktop <<EOL
#[Desktop Entry]
#Encoding=UTF-8
#Name=Postman
#Exec=postman
#Icon=/opt/Postman/resources/app/assets/icon.png
#Terminal=false
#Type=Application
#Categories=Development;
#EOL

#Backgrounds#
BG_FILE="$DIR/fire-tiger_2560x1440.jpg"
wget -q "https://drive.google.com/uc?id=1Zpofyv2vMcVUv7nfxYaKG2uKakT8baxS&export=download" -O $BG_FILE
mkdir -p $DIR/Pictures
cp $BG_FILE $DIR/Pictures
rm -f $BG_FILE

#VS Code#
#Settings
mkdir -p $DIR/.config/Code/User/
cp settings/vscode/* $DIR/.config/Code/User/

#SSH Keys##
SSH_DIR="$DIR/.ssh"
mkdir -p $SSH_DIR
LINK_DATA=`ruby get_onedrive_dl_link.rb $SHARING_LINK $SHARING_PASSWORD`
SSH_KEY_NAME="$(cut -f1 <<<$LINK_DATA)"
SSH_KEY_URL="$(cut -f2 <<<$LINK_DATA)"
wget -q $SSH_KEY_URL -O $SSH_DIR/${SSH_KEY_NAME}
chown -R $username $SSH_DIR
chmod -R 700 $SSH_DIR

#AWS#
#CLI Setup
aws configure set default.region us-east-1
aws configure set default.output json

# VSCode
#Extensions
code --install-extension --force luqimin.velocity #Apache Velocity
code --install-extension --force aws-amplify.aws-amplify-vscode #AWS Amplify API
code --install-extension --force ms-azuretools.vscode-docker #Docker
code --install-extension --force dbaeumer.vscode-eslint #ESLint
code --install-extension --force donjayamanne.githistory #Git History
code --install-extension --force eamodio.gitlens #GitLens
code --install-extension --force kumar-harsh.graphql-for-vscode #GraphQL for VSCode
code --install-extension --force slevesque.vscode-hexdump #hexdump for VSCode
code --install-extension --force christian-kohler.npm-intellisense #npm Intellisense
code --install-extension --force zhuangtongfa.material-theme #One Dark Pro
code --install-extension --force msjsdiag.vscode-react-native # React Native Tools
code --install-extension --force chenxsan.vscode-standardjs # StandardJS - Javascript Standard Style
code --install-extension --force vscode-icons-team.vscode-icons #vscode-icons
code --install-extension --force hashicorp.terraform # Terraform / HCL

#Finalize Desktop
dbus-launch dconf load / < settings/dconf/dconf-select-settings.config

#Project Directory#
mkdir $DIR/Development

#Git#
#Basic Config
git config --global user.email $email
git config --global user.name "$name"
git config --global push.default simple
