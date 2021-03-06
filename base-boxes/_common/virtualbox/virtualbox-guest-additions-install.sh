# Download and install latest guest additions
echo "=== Installing the latest Virtualbox guest additions ==="
wget -nv https://download.virtualbox.org/virtualbox/LATEST.TXT
latest=`cat LATEST.TXT`
rm -f LATEST.TXT
virtualBoxFileName="VBoxGuestAdditions_${latest}.iso"
wget "https://download.virtualbox.org/virtualbox/$latest/$virtualBoxFileName"
mkdir /media/iso
mount -o loop $virtualBoxFileName /media/iso
/media/iso/VBoxLinuxAdditions.run
/sbin/rcvboxadd quicksetup all
umount -f /media/iso
rm -f $virtualBoxFileName
