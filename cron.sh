#!/bin/bash
#
# This script is intended to be used to manage cronjobs on CentOS 7 devices
# 

#check for the Trend Micro Deep Security Agent
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")

if [[ $dsagent == *"installed"* ]]
then
  #send a heartbeat to the Deep Security Manager every 30 minutes.
  echo "*/30 * * * * /opt/ds_agent/dsa_control -m >> /dev/null 2>&1" | crontab -
fi

#update scripts at 2:30am
(crontab -l ; echo "30 2 * * * /root/scripts/plexity/update.sh | /root/scripts/plexity/notify.sh") | crontab -

#rebuild cronjobs at 2:40am
(crontab -l ; echo "40 2 * * * /root/scripts/plexity/cron.sh | /root/scripts/plexity/notify.sh") | crontab -

if [[ $dsagent == *"installed"* ]]
then
  #update packages other than kernel at 3:30am
  (crontab -l ; echo "45 2 * * * /usr/bin/yum -y -e 0 -x kernel* update | /root/scripts/plexity/notify.sh") | crontab -
else
  (crontab -l ; echo "45 2 * * * /usr/bin/yum -y -e 0 update | /root/scripts/plexity/notify.sh") | crontab -
fi

if [[ $dsagent == *"installed"* ]]
then
  #update the kernel to the latest supported by Deep Security at 4am
  (crontab -l ; echo "0 3 * * * /root/scripts/plexity/ds_kernel.sh | /root/scripts/plexity/notify.sh") | crontab -
fi

#check for Plex Media Server
plexmediaserver=$(yum info plexmediaserver.x86_64 | grep "Repo        : installed")

if [[ $plexmediaserver == *"installed"* ]]
then
  #update plexmediaserver at 4:30am
  (crontab -l ; echo "30 3 * * * /root/scripts/plexupdate/plexupdate.sh | /root/scripts/plexity/notify.sh") | crontab -
fi

#Send log file with notify.sh
(crontab -l ; echo "0 4 * * * cat /mnt/files/log | /root/scripts/plexity/notify.sh") | crontab -
