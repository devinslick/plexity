#!/bin/bash
#
# This script is intended to be used to manage cronjobs on CentOS 7 devices without the plex server installed.
# 

#update scripts from repo at 2:30am
echo "30 2 * * * /root/scripts/plexity/update.sh" | crontab -
#rebuild cronjobs at 3am
(crontab -l ; echo "0 3 * * * /root/scripts/plexity/cron.sh > /dev/null 2>&1") | crontab -
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
if [[ $dsagent == *"installed"* ]]
then
  #update installed packages other than kernel at 3:30am
  (crontab -l ; echo "30 3 * * * /usr/bin/yum -y -e 0 -x kernel* update") | crontab -
  #update the kernel to the latest supported by Deep Security at 4am
  (crontab -l ; echo "0 4 * * * /root/scripts/plexity/ds_kernel.sh") | crontab -
  #send a heartbeat to the Deep Security Manager every 30 minutes.
  (crontab -l ; echo "*/30 * * * * /opt/ds_agent/dsa_control -m > /dev/null 2>&1") | crontab -
else
  #update installed packages at 4am
  (crontab -l ; echo "0 4 * * * /usr/bin/yum -y -e 0 update") | crontab -
fi
plexmediaserver=$(yum info plexmediaserver.x86_64 | grep "Repo        : installed")
if [[ $plexmediaserver == *"installed"* ]]
then
  #update plexmediaserver at 4:30am
  (crontab -l ; echo "30 4 * * * /root/scripts/plexupdate/plexupdate.sh") | crontab -
fi

#filebot update not working from cron
#(crontab -l ; echo "0 3 * * * /root/scripts/filebot/update-filebot.sh") | crontab -
