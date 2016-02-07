#!/bin/bash
echo This script is intended to setup a Plex media server on CentOS 7.
read -n 1 -p "Would you like to continue? [y/n]: " installContinue
if [ $installContinue = 'n' ]; then
  exit
fi

sudo bash
yum -y update

grep -q ^flags.*\ hypervisor /proc/cpuinfo && echo "This machine is a virtual machine, installing VMware Tools..." && yum -y install open-vm-tools

echo "Installing server prerequisites and dependencies..."
yum -y install yum make gcc pam-devel wget git

echo "Installing various media plugins applications..."
yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm http://linuxdownload.adobe.com/linux/x86_64/adobe-release-x86_64-1.0-1.noarch.rpm
yum -y install ffmpeg libdvdcss gstreamer{,1}-plugins-ugly gstreamer-plugins-bad-nonfree gstreamer1-plugins-bad-freeworld

read -n 1 -p "Would you like to install HandBrake? [y/n]: " installHandBrake
if [ $installHandBrake = 'y' ]; then
  yum -y install HandBrake-{gui,cli}
fi

read -n 1 -p "Would you like to install SMPlayer and VLC Media Players? [y/n]: " installVLC
if [ $installVLC = 'y' ]; then
  yum -y install vlc
fi

read -n 1 -p "Would you like to install Transmission for torrenting? [y/n]: " installTransmission
if [ $installTransmission = 'y' ]; then
  echo Installing transmission...
  yum -y install epel-* transmission transmission-daemon
  chkconfig transmission-daemon on
fi

if [ $installTransmission = 'y' ]; then
  echo "FileBot is a tool used to help automate renaming media."
  echo "Since you chose to install Transmission, I'll go ahead and install FileBot for you as well.  You're welcome!"
  yum -y unzip java
  wget http://downloads.sourceforge.net/project/filebot/filebot/FileBot_4.6.1/FileBot_4.6.1-portable.zip?r=http%3A%2F%2Fwww.filebot.net%2F&ts=1449410469&use_mirror=iweb
  mkdir -p /scripts/filebot/
  mv FileBot_4.6* /scripts/filebot/
  unzip /scripts/filebot/FileBot_4.6* -d /scripts/filebot/ -x *.exe
  rm -rf /root/scripts/filebot/*.zip
  echo "FileBot has been installed!"
fi

echo "Trend Micro Deep Security..."
echo "Please note: This will require you know the server address of your Deep Security Manager."
read -n 1 -p "Would you like to install the Deep Security Agent? [y/n]: " installDeepSecurity
if [ $installDeepSecurity = 'y' ]; then
  echo Installing Deep Security Agent...
  echo "Kernel updates should only be installed if they've been confirmed compatible with Deep Security."
  echo "To avoid incompatibily, I'm excluding kernel updates from yum."
  echo "Don't worry, I'll give you a script and a cronjob to automatically update to the latest supported kernel!"
  grep -q -F 'exclude=kernel* redhat-release*' foo.bar || echo 'exclude=kernel* redhat-release*' >> /etc/yum.conf
  echo -n "Enter your Deep Security Manager address (eg: dsm.mydomain.com) : "
  read dsm
  wget https://$dsm:4119/software/agent/RedHat_EL7/x86_64/ -O /tmp/agent.rpm --no-check-certificate --quiet
  rpm -ihv /tmp/agent.rpm
  /opt/ds_agent/dsa_control -a dsm://$dsm:4120/
  chkconfig iptables off
  systemctl stop firewalld, systemctl disable firewalld
  sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
fi

echo Importing scripts from github...
mkdir -p /root/scripts/
cd /root/scripts
git clone https://github.com/devinslick/plexity.git
git clone https://github.com/devinslick/plexupdate.git

echo Installing Plex...
echo "If you have a PlexPass this script can automatically download and install the latest PlexPass Plex Server build."
read -n 1 -p "Do you have a PlexPass (y/n)? " plexpass
if [ $plexpass = 'y' ]; then
  echo -n "Enter your PlexPass username or email address: "
  read plexuser
  echo -n "Enter your PlexPass password: "
  read plexpassword
  echo -e "EMAIL="$plexuser > '/root/.plexupdate'
  echo -e "PASS="$plexpassword >> '/root/.plexupdate'
  echo 'DOWNLOADDIR=.' >> '/root/.plexupdate'
  echo 'RELEASE=64-bit' >> '/root/.plexupdate'
  echo 'KEEP=no' >> '/root/.plexupdate'
  echo 'FORCE=yes' >> '/root/.plexupdate'
  echo 'PUBLIC=no' >> '/root/.plexupdate'
  echo 'AUTOINSTALL=yes' >> '/root/.plexupdate'
  echo 'AUTODELETE=yes' >> '/root/.plexupdate'
  echo 'AUTOUPDATE=yes' >> '/root/.plexupdate'
  echo 'AUTOSTART=yes' >> '/root/.plexupdate'
fi

echo Setting up cronjobs...
sh /root/scripts/cron.sh

echo Done
