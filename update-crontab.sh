#!/bin/bash
#
# This script is intended to be used to manage cronjobs on CentOS 7 devices
#
echo "Rebuilding Plexity cron jobs for "$HOSTNAME"..."
echo -en "Checking for the Trend Micro Deep Security Agent:"
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
echo -en "\nChecking for the Plex Media Server:"
plexmediaserver=$(yum info plexmediaserver.x86_64 | grep "Repo        : installed")

if [[ $dsagent == *"installed"* ]]
then
  #send a heartbeat to the Deep Security Manager every 30 minutes.
  echo "*/30 * * * * /opt/ds_agent/dsa_control -m >> /dev/null 2>&1" | crontab -u plexity -
fi

#update scripts at 2:30am
(crontab -u plexity -l ; echo "30 2 * * * /opt/plexity/update-scripts.sh | /opt/plexity/notify.sh") | crontab -u plexity -

#rebuild cronjobs at 2:40am
(crontab -u plexity -l ; echo "40 2 * * * /opt/plexity/update-crontab.sh | /opt/plexity/notify.sh") | crontab -u plexity -

if [[ $dsagent == *"installed"* ]]
then
  #update packages other than kernel at 3:30am
  (crontab -u plexity -l ; echo "45 2 * * * /opt/plexity/update-centos.sh | /opt/plexity/notify.sh") | crontab -u plexity -
else
  (crontab -u plexity -l ; echo "45 2 * * * /opt/plexity/update-centos.sh | /opt/plexity/notify.sh") | crontab -u plexity -
fi

if [[ $dsagent == *"installed"* ]]
then
  #update the kernel to the latest supported by Deep Security at 4am
  (crontab -u plexity -l ; echo "0 3 * * * /opt/plexity/ds_kernel.sh | /opt/plexity/notify.sh") | crontab -u plexity -
fi

if [[ $plexmediaserver == *"installed"* ]]
then
  #update plexmediaserver at 4:30am
  (crontab -u plexity -l ; echo "30 3 * * * /opt/plexity/update-plex.sh") | crontab -u plexity -
fi
echo -e "\nCrontab has been updated:"
crontab -u plexity -l
