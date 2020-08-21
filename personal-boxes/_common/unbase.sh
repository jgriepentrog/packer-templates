#!/bin/bash

# Unwind the base box set up

echo "=== Removing root password/disable account ==="
passwd -dl root

echo "=== Removing vagrant account ==="
deluser --remove-home vagrant
delgroup vagrant
rm -f etc/sudoers.d/vagrant

echo "=== Removing SSH server ==="
apt-get remove -y openssh-server
rm -f /etc/ssh/sshd_config
apt-get autoremove -y
