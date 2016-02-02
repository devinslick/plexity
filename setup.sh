#!/bin/bash

sudo bash
su - root

echo "Installing prerequisites and dependencies..."
yum -y install make gcc pam-devel git wget open-vm-tools java

echo "Installing media libraries and video management applications..."
yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm http://linuxdownload.adobe.com/linux/x86_64/adobe-release-x86_64-1.0-1.noarch.rpm
yum -y install vlc smplayer ffmpeg HandBrake-{gui,cli} libdvdcss gstreamer{,1}-plugins-ugly gstreamer-plugins-bad-nonfree gstreamer1-plugins-bad-freeworld

echo Installing transmission...
yum -y install epel-* transmission transmission-daemon
chkconfig transmission-daemon on

echo Importing scripts from github...
mkdir /root/scripts/
cd /root/scripts
git clone https://github.com/devinslick/plexity.git
chmod +x /root/scripts/plexity/*.sh
git clone https://github.com/devinslick/plexupdate.git

echo Installing Deep Security Agent...
echo exclude=kernel* redhat-release* >> /etc/yum.conf
wget https://Slick-DSM.devinslick.com:4119/software/agent/RedHat_EL7/x86_64/ -O /tmp/agent.rpm --no-check-certificate --quiet
rpm -ihv /tmp/agent.rpm
/opt/ds_agent/dsa_control -a dsm://Slick-DSM.devinslick.com:4120/
#no firewall, using ds firewall; Deep Security doesn’t support SELinux
chkconfig iptables off
systemctl stop firewalld, systemctl disable firewalld
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

echo Installing and configuring automatic updates
yum -y install yum-cron
systemctl start yum-cron
sed -ie 's/# assumeyes = True/assumeyes = True/' /etc/yum/yum-cron.conf
sed -ie 's/apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
sed -ie 's/random_sleep = 360/random_sleep = 0/' /etc/yum/yum-cron.conf
sed -ie 's/assumeyes = True/assumeyes = False/' /etc/yum/yum-cron.conf
systemctl restart yum-cron
yum -y update

echo Installing Filebot
Wget http://downloads.sourceforge.net/project/filebot/filebot/FileBot_4.6.1/FileBot_4.6.1-portable.zip?r=http%3A%2F%2Fwww.filebot.net%2F&ts=1449410469&use_mirror=iweb
Yum -y unzip

echo Setting up cronjobs...
echo '0 4 * * * /root/scripts/plexity/ds_kernel.sh' | crontab -
#filebot update not working from cron
#(crontab -l ; echo "0 3 * * * /root/scripts/filebot/update-filebot.sh") | crontab -
(crontab -l ; echo "0 3 * * * /root/scripts/plexupdate/plexupdate.sh") | crontab -
(crontab -l ; echo "30 3 * * * /usr/bin/yum -y -R 120 -d 0 -e 0 -x kernel* update) | crontab -
(crontab -l ; echo "*/30 * * * * /opt/ds_agent/dsa_control -m > /dev/null 2>&1") | crontab -
