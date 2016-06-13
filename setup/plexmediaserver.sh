#!/bin/bash
echo This script will setup a Plex media server on CentOS 7.

read -n 1 -p "Would you like to continue? [y/n]: " installContinue
if [ $installContinue = 'n' ]; then
  exit
fi

read -n 1 -p "Would you like to install the Plex Media Server on this machine? [y/n]: " installPlex
if [ $installPlex = 'y' ]; then
  echo "Adding plexupdate scripts for automatic updates..."
  git clone https://github.com/devinslick/plexupdate.git /opt/plexity-plexupdate/
  echo Installing Plex...
  echo "If you have a PlexPass this script can automatically download and install the latest PlexPass Plex Server build."
  read -n 1 -p "Do you have a PlexPass (y/n)? " plexpass
  if [ $plexpass = 'y' ]; then
  echo "Enter your PlexPass username or email address: "
    read plexuser
    echo -n "Enter your PlexPass password: "
    read plexpassword
    echo -e "EMAIL="$plexuser > '/var/plexity/plexupdate.settings'
    echo -e "PASS="$plexpassword >> '/var/plexity/plexupdate.settings'
    echo 'DOWNLOADDIR=.' >> '/var/plexity/plexupdate.settings'
    echo 'RELEASE=64' >> '/var/plexity/plexupdate.settings'
    echo 'KEEP=no' >> '/var/plexity/plexupdate.settings'
    echo 'FORCE=yes' >> '/var/plexity/plexupdate.settings'
    echo 'PUBLIC=no' >> '/var/plexity/plexupdate.settings'
    echo 'AUTOINSTALL=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTODELETE=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTOUPDATE=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTOSTART=yes' >> '/var/plexity/plexupdate.settings'
    ln -s /var/plexity/plexupdate.settings /root/.plexupdate
  else
    echo 'DOWNLOADDIR=.' > '/var/plexity/plexupdate.settings'
    echo 'RELEASE=64' >> '/var/plexity/plexupdate.settings'
    echo 'KEEP=no' >> '/var/plexity/plexupdate.settings'
    echo 'FORCE=yes' >> '/var/plexity/plexupdate.settings'
    echo 'PUBLIC=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTOINSTALL=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTODELETE=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTOUPDATE=yes' >> '/var/plexity/plexupdate.settings'
    echo 'AUTOSTART=yes' >> '/var/plexity/plexupdate.settings'
    ln -s /var/plexity/plexupdate.settings /root/.plexupdate
  fi
  echo "A network drive is often used to store Plex media files."
  echo "Example: \\192.168.1.2\Media"
  echo "Note: if you press ENTER and do not enter a path then local storage will be used instead."
  echo "Please enter the path to your media share: "
  read networklocation
  if [ ${#networklocation} -ge 5 ]
  then
    echo $networklocation > /var/plexity/nas.path
    echo "Your media share location was saved to /var/plexity/nas.path"
    mkdir '/media/share'
    echo '//192.168.1.2/Public /media/share cifs username=guest,uid=1002,gid=1001,iocharset=utf8,file_mode=0777,dir_mode=0777 0 0' >> /etc/fstab
    mount -a
  else
    echo "No network path entered.    Assuming local storage."
  fi
  echo Installing plex media server
  /opt/plexity-plexupdate/plexupdate.sh
fi

