#!/bin/bash
echo This script will setup a Transmission server on CentOS 7.
 
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
  sleep 10
  systemctl stop transmission-daemon
  sleep 2
  sed -i 's|"rpc-whitelist-enabled": true,|"rpc-whitelist-enabled": false,|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  sed -i 's|"incomplete-dir-enabled": false,|"incomplete-dir-enabled": true,|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  sed -i 's|"/var/lib/transmission/Downloads"|"/media/files/Complete"|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  sed -i 's|"/var/lib/transmission/Downloads"|"/media/files/Incomplete"|g' /var/lib/transmission/.config/transmission-daemon/settings.json /var/lib/transmission/.config/transmission-daemon/settings.json
  systemctl start transmission-daemon
fi



