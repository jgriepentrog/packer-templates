USERNAME=$1
SCRIPT=`realpath $2`
SCRIPT_DIR=`dirname $SCRIPT`
cd $SCRIPT_DIR
chmod +x $SCRIPT
sudo -u $USERNAME $SCRIPT $3 $4