#####
# Set up the base box to work with Vagrant
# Follows these requirements: https://www.vagrantup.com/docs/boxes/base.html
#####

SSH_USER="vagrant"
SSH_USER_HOME="/home/${SSH_USER}"
SSH_USER_SSH_DIR="${SSH_USER_HOME}/.ssh"
VAGRANT_KEY_URL="https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub"

### Set up SSH ###
echo "=== Setting up SSH directory and permissions ==="
if [ ! -d "${SSH_USER_SSH_DIR}" ]; then
  mkdir "${SSH_USER_SSH_DIR}"
fi
chmod -R 700 ${SSH_USER_SSH_DIR}

echo "=== Authorizing the well known (insecure) Vagrant SSH key ==="
curl -Ss ${VAGRANT_KEY_URL} >> ${SSH_USER_SSH_DIR}/authorized_keys
chmod 600 ${SSH_USER_SSH_DIR}/authorized_keys

echo "=== Ensure SSH dir and contents are owned by SSH user ==="
chown -R ${SSH_USER} ${SSH_USER_SSH_DIR}
chgrp -R ${SSH_USER} ${SSH_USER_SSH_DIR}

### Set up passwordless sudo ###
#echo "=== Granting ${SSH_USER} passwordless sudo access ==="
#echo "${SSH_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant

### Disable reverse DNS lookups ###
echo "UseDNS no" >> /etc/ssh/sshd_config