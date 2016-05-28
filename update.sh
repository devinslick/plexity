#!/bin/bash

#creating functions
function check-installed
{
  #plexmediaserver=$(yum info plexmediaserver.x86_64 | grep "Repo        : installed")
  dsagent=$(yum list ds_agent.x86_64)
  plexmediaserver=$(yum list plexmediaserver)
}

function update-scripts
{
  cd /opt/plexity
  git reset HEAD > /dev/null 2>&1
  git checkout -- . > /dev/null 2>&1
  echo "Updating Plexity from Github repository..."
  OUTPUT="$(sudo git pull -f)"
  if [[ $OUTPUT == *"Already up-to-date"* ]]
  then
     echo $(date +'%b %d %H:%M:%S')" Plexity scripts are already up to date" | tee -a /var/log/plexity/$(date '+%Y%m%d').log
  else
     echo $(date +'%b %d %H:%M:%S')" Plexity script update complete!" | tee -a /var/log/plexity/$(date '+%Y%m%d').log
  fi
}

function update-cronjobs
{
  dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
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
}
#
check-installed
update-scripts
update-cronjobs

#if a log file today already exists...
if [ -f /var/log/plexity/$(date '+%Y%m%d').log ]; then
  #if file contains "Logs sent"
  if grep -q "Logs sent" /var/log/plexity/$(date '+%Y%m%d').log; then
    exit
  else
    /opt/plexity/gatherLogs.sh
  fi
#if a log file for today does not already exist...
else 
  if [[ $dsagent == *"installed"* ]]; then
    sudo sudo yum -y -e 0 update -x 'kernel*'
    sudo cat /var/log/yum.log | grep "$(date +'%b %d')" >> /var/log/plexity/$(date '+%Y%m%d').log
    echo -e $(date +'%b %d %H:%M:%S')' Checked for updates to CentOS packages' >> /var/log/plexity/$(date '+%Y%m%d').log
    /opt/plexity/ds_kernel.sh
  else
    sudo sudo yum -y -e 0 update
    sudo grep -v plexmediaserver /var/log/yum.log | grep "$(date +'%b %d %H')" >> /var/log/plexity/$(date '+%Y%m%d').log
  fi
  if [[ $plexmediaserver == *"installed"* ]]; then
    sudo /opt/plexity-plexupdate/plexupdate.sh
    sudo grep -v plexmediaserver /var/log/yum.log | grep "$(date +'%b %d')" >> /var/log/plexity/$(date '+%Y%m%d').log
    /opt/plexity-filebot/update-filebot.sh
  fi
  /opt/plexity/gatherLogs.sh
  echo -e $(date +'%b %d %H:%M:%S')' Logs sent' >> /var/log/plexity/$(date '+%Y%m%d').log
fi
