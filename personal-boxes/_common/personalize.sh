#!/bin/bash

# Add new, personal user account
USER_NAME=$1
USER_PASSWORD=$2

# Add user
adduser $USER_NAME --disabled-password --gecos "" --shell /bin/bash

# Add user to groups
usermod -aG sudo $USER_NAME
usermod -aG vboxsf $USER_NAME

# Set password
HASHED_PASSWORD=`echo $USER_PASSWORD | mkpasswd -R 1000000 -m sha512crypt -s`
echo ${USER_NAME}:${HASHED_PASSWORD} | chpasswd -e

# Create run directory
USER_ID=`id -u $USER_NAME`
USER_RUN_PATH="/run/user/$USER_ID"
mkdir -p $USER_RUN_PATH
chown $USER_NAME $USER_RUN_PATH
chgrp $USER_NAME $USER_RUN_PATH
chmod 700 $USER_RUN_PATH
