#!/bin/bash
echo This script is intended to setup a Plex media server on CentOS 7.
read -n 1 -p "Would you like to continue? [y/n]: " installContinue
if [ $installContinue = 'n' ]; then
  exit
fi

echo "Creating new plexity service account..."
adduser -g wheel plexity
echo plexity:$(date +%s | sha256sum | base64 | head -c 32) | chpasswd
sed -i 's/Defaults:root !requiretty/#Defaults:root !requiretty/g' /etc/sudoers /etc/sudoers
sed -i 's/root    ALL=(ALL)       ALL/%wheel    ALL=(ALL)       ALL/g' /etc/sudoers /etc/sudoers
sed -i 's/# %wheel/%wheel/g' /etc/sudoers /etc/sudoers

yum -y update

grep -q ^flags.*\ hypervisor /proc/cpuinfo && echo "This machine is a virtual machine, installing VMware Tools..." && yum -y install open-vm-tools

echo "Installing server prerequisites and dependencies..."
yum -y install yum make gcc pam-devel wget git mailx

echo "Installing various media plugins applications..."
yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm http://linuxdownload.adobe.com/linux/x86_64/adobe-release-x86_64-1.0-1.noarch.rpm
yum -y install ffmpeg libdvdcss gstreamer{,1}-plugins-ugly gstreamer-plugins-bad-nonfree gstreamer1-plugins-bad-freeworld

echo "Your email address can be used to receive nightly reports when jobs complete."
echo "You may also wish to use your Pushover.net email account or another service"
echo -n "Enter the email address to receive updates: "
read emailaddress
if [ ${#emailaddress} -ge 5 ]
then
   echo $emailaddress > /var/plexity/emailaddress
   echo "Email address saved to /var/plexity/emailaddress"
else
   echo "No email address entered, skipping."
fi

echo "If you're familiar with Pushover.net, you may wish to create a custom application to receive notifications."
echo "Create a custom application in pushover.net for the API key.   Without this, notifications will be transferred over email."
echo "If you provide neither a User key or API key then notifications will fall back to your previously entered email address."
echo -n "Enter your Pushover.net User key or just [ENTER] to skip:"
read pushoveruser
echo $pushoveruser > /var/plexity/pushover.user.key

echo -n "Enter your Pushover.net API key or just [ENTER] to skip:"
read pushoverapi
if [ ${#pushoverapi} -ge 5 ]
then
   echo $pushoverapi > /var/plexity/pushover.api.key
   echo "Pushover API key saved to /var/plexity/pushover.api.key"
else
   echo "No Pushover API key entered, skipping."
fi


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
  mkdir -p /opt/filebot/
  mv FileBot_4.6* /opt/filebot/
  unzip /opt/filebot/FileBot_4.6* -d /opt/filebot/ -x *.exe
  rm -rf /opt/filebot/*.zip
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
cd /opt/
git clone https://github.com/devinslick/plexity.git
mkdir /var/plexity
read -n 1 -p "Would you like to install the Plex Media Server on this machine? [y/n]: " installPlex
if [ $installPlex = 'y' ]; then
  echo "Adding plexupdate scripts for automatic updates..."
  mkdir /opt/plexupdate /var/plexupdate
  git clone https://github.com/devinslick/plexupdate.git
  echo Installing Plex...
  echo "If you have a PlexPass this script can automatically download and install the latest PlexPass Plex Server build."
  read -n 1 -p "Do you have a PlexPass (y/n)? " plexpass
  if [ $plexpass = 'y' ]; then
  echo "Enter your PlexPass username or email address: "
    read plexuser
    echo -n "Enter your PlexPass password: "
    read plexpassword
    echo -e "EMAIL="$plexuser > '/var/plexupdate/settings.conf'
    echo -e "PASS="$plexpassword >> '/var/plexupdate/settings.conf'
    echo 'DOWNLOADDIR=.' >> '/var/plexupdate/settings.conf'
    echo 'RELEASE=64' >> '/var/plexupdate/settings.conf'
    echo 'KEEP=no' >> '/var/plexupdate/settings.conf'
    echo 'FORCE=yes' >> '/var/plexupdate/settings.conf'
    echo 'PUBLIC=no' >> '/var/plexupdate/settings.conf'
    echo 'AUTOINSTALL=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTODELETE=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTOUPDATE=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTOSTART=yes' >> '/var/plexupdate/settings.conf'
    ln -s /root/.plexupdate /var/plexupdate/settings.conf
  else
    echo 'DOWNLOADDIR=.' > '/var/plexupdate/settings.conf'
    echo 'RELEASE=64' >> '/var/plexupdate/settings.conf'
    echo 'KEEP=no' >> '/var/plexupdate/settings.conf'
    echo 'FORCE=yes' >> '/var/plexupdate/settings.conf'
    echo 'PUBLIC=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTOINSTALL=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTODELETE=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTOUPDATE=yes' >> '/var/plexupdate/settings.conf'
    echo 'AUTOSTART=yes' >> '/var/plexupdate/settings.conf'
    ln -s /var/plexupdate/settings.conf /root/.plexupdate
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
  else
    echo "No network path entered.    Assuming local storage."
  fi
fi

echo Setting up cronjobs...
sh /opt/plexity/update-crontab.sh
echo Done
