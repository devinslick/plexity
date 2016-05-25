#!/bin/bash
echo This script is intended to setup a Plex media server on CentOS 7.
read -n 1 -p "Would you like to continue? [y/n]: " installContinue
if [ $installContinue = 'n' ]; then
  exit
fi

mkdir -p /var/plexity/ /var/log/plexity /opt/plexity-filebot/
chmod 775 /var/log/plexity
chmod g+s /var/log/plexity 
setfacl -d -m g::rwx /var/log/plexity
setfacl -d -m o::rwx /var/log/plexity

echo "Creating new plexity service account..."
adduser -g wheel plexity
echo plexity:$(date +%s | sha256sum | base64 | head -c 32) | chpasswd
sed -i 's/Defaults:root !requiretty/#Defaults:root !requiretty/g' /etc/sudoers /etc/sudoers
sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers /etc/sudoers
sed -i 's/root    ALL=(ALL)       ALL/%wheel    ALL=(ALL)       ALL/g' /etc/sudoers /etc/sudoers
sed -i 's/# %wheel/%wheel/g' /etc/sudoers /etc/sudoers

if grep -q '#plexity' /etc/ssh/sshd_config; then
  echo "SSH appears to have already been configured by plexity setup; skipping..."
else
  echo "Depending on your perimeter firewall, SSH will be allowed for all source addresses."
  echo "To connect from outside of your network you will need to use key-based authentication."
  cp -n /etc/ssh/sshd_config /etc/ssh/sshd_config.plexitybackup
  sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no    #plexity-no-cra/g' /etc/ssh/sshd_config
  sed -i 's/PasswordAuthentication yes/#PasswordAuthentication yes  #plexity-pass-comment/g' /etc/ssh/sshd_config
  echo "PasswordAuthentication no   #plexity-passauthno" >> /etc/ssh/sshd_config
  echo -e 'Match Address '$(ip -o -f inet addr show | awk '/scope global/ {print $6}' | sed 's/255/0/g')/$(ip -o -f inet addr show | awk '/scope global/{print $4}' | cut -f 2 -d "/")' \t\t#plexity-matchaddr' >> /etc/ssh/sshd_config
  echo -e '\tPasswordAuthentication yes\t#plexity-matchaddrpathauth' >> /etc/ssh/sshd_config
fi

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
  yum -y install epel-* transmission transmission-daemon unzip unrar
  chkconfig transmission-daemon on
  echo "FileBot is a tool used to help automate renaming media."
  echo "Since you chose to install Transmission, I'll go ahead and install FileBot for you as well.  You're welcome!"
  yum -y install java
  wget http://iweb.dl.sourceforge.net/project/filebot/filebot/FileBot_4.6/FileBot_4.6-portable.zip
  #wget http://iweb.dl.sourceforge.net/project/filebot/filebot/FileBot_4.7/FileBot_4.7-portable.zip
  #4.7 is not working yet but will be added soon
  mv FileBot_4.6* /opt/plexity-filebot/
  unzip /opt/plexity-filebot/FileBot_4.6* -d /opt/plexity-filebot/ -x *.exe
  rm -rf /opt/plexity-filebot/*.zip
  ln -s /var/lib/transmission/.config/transmission-daemon/settings.json /var/plexity/transmission.settings
  mkdir -p /media/files/Complete
  mkdir -p /media/files/Incomplete
  chmod -R 777 /media/files/
  sleep 3
  systemctl stop transmission-daemon
  sleep 2
  sed -i 's|"rpc-whitelist-enabled": true,|"rpc-whitelist-enabled": false,|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  sed -i 's|"incomplete-dir-enabled": false,|"incomplete-dir-enabled": true,|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  sed -i 's|"/var/lib/transmission/Downloads"|"/media/files/Complete"|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  sed -i 's|"/var/lib/transmission/Downloads"|"/media/files/Incomplete"|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  systemctl start transmission-daemon
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
  sleep 15
  chkconfig iptables off
  systemctl stop firewalld
  systemctl disable firewalld
  sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
  /opt/ds_agent/dsa_control -r
  /opt/ds_agent/dsa_control -a dsm://$dsm:4120/  
fi

CURRENTPATH="`dirname \"$0\"`"
if [ $CURRENTPATH='/opt/plexity' ];
then
  echo 'setup.sh is running from /opt/plexity/, skipping git clone...'
else
  echo Importing scripts from github...
  git clone https://github.com/devinslick/plexity.git /opt/plexity
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

echo Setting up cronjobs...
/opt/plexity/update-crontab.sh
echo Done

echo Finalizing updates, will restart if necessary...
yum -y update
if [ $installDeepSecurity = 'y' ]; then
  /opt/plexity/ds_kernel.sh
fi
