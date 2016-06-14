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
  echo "*/30 * * * * /opt/ds_agent/dsa_control -m >> /dev/null 2>&1" | sudo crontab -u plexity -
fi

#update scripts at 2:00am
(sudo crontab -u plexity -l ; echo "0 2 * * * /opt/plexity/update-scripts.sh") | sudo crontab -u plexity -

#rebuild cronjobs at 2:15am
(sudo crontab -u plexity -l ; echo "15 2 * * * /opt/plexity/update-crontab.sh") | sudo crontab -u plexity -
(sudo crontab -u plexity -l ; echo "45 2 * * * /opt/plexity/update-centos.sh") | sudo crontab -u plexity -

if [[ $dsagent == *"installed"* ]]
then
  #update the kernel to the latest supported by Deep Security at 4am
  (sudo crontab -u plexity -l ; echo "0 3 * * * /opt/plexity/ds_kernel.sh") | sudo crontab -u plexity -
fi

if [[ $plexmediaserver == *"installed"* ]]
then
  #update filebot at 2:30am
  (sudo crontab -u plexity -l ; echo "30 2 * * * /opt/plexity-filebot/update-filebot.sh") | sudo crontab -u plexity -
  #update plexmediaserver at 4:30am
  (sudo crontab -u plexity -l ; echo "30 3 * * * /opt/plexity/update-plex.sh") | sudo crontab -u plexity -
fi
(sudo crontab -u plexity -l ; echo "0 4 * * * /opt/plexity/gatherLogs.sh") | sudo crontab -u plexity -
echo -e $(date +'%b %d %H:%M:%S') "Plexity crontab has been updated." | tee -a /var/log/plexity/$(date '+%Y%m%d').log
sudo crontab -u plexity -l
