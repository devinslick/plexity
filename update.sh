#!/bin/bash

#creating functions
function check-installed
{
  #plexmediaserver=$(yum info plexmediaserver.x86_64 | grep "Repo        : installed")
  dsagent=$(yum list ds_agent.x86_64)
  plexmediaserver=$(yum list plexmediaserver)
}

#  Check for kernel updates compatible with the Trend Micro Deep Security Agent
function dskernel
{
  installed=$(uname -r)
  installed=$(sed 's/.x86_64/ /g' <<<"$installed")
  echo "Running kernel: "$installed
  wget -q "http://files.trendmicro.com/documentation/guides/deep_security/Kernel%20Support/9.6/Deep_Security_96_kernels_EN.html"
  RESULTS=$(sed -e '/centos7 (64-bit)/,/CloudLinux Kernels/!d' Deep_Security_96_kernels_EN.html | grep -F '.' | tail -1) > /dev/null 2>&1
  rm -f Deep_Security_96_kernels_EN.html* > /dev/null 2>&1
  RESULTS=$(echo $RESULTS | sed -e :a -e 's/<[^>]*>//g;/</N;//ba')
  RESULTS=$(sed 's/.x86_64/ /g' <<<"$RESULTS")
  if [[ $installed == "$RESULTS" ]]
  then
    echo $(date +'%b %d %H:%M:%S')" You are running the latest kernel supported by Deep Security" >> /var/log/plexity/$(date '+%Y%m%d').log
  else
    echo Attempting to install CentOS 7 kernel: $RESULTS
    install=$(sudo yum -y install kernel-$RESULTS)
    if [[ $install == *"Nothing to do"* ]]
    then
      echo $(date +'%b %d %H:%M:%S') " Kernel installation was attempted but there was nothing to do." >> /var/log/plexity/$(date '+%Y%m%d').log
    else
      echo $(date +'%b %d %H:%M:%S') " Kernel updated from $installed to $RESULTS" >> /var/log/plexity/$(date '+%Y%m%d').log
      shutdown -r +1 "Server is rebooting for kernel upgrade..." 
    fi
  fi
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
  #dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
  #plexmediaserver=$(yum info plexmediaserver.x86_64 | grep "Repo        : installed")
  sudo crontab -u plexity -r
  if [[ $dsagent == *"installed"* ]]
  then
    #send a heartbeat to the Deep Security Manager every 30 minutes.
    (sudo crontab -u plexity -l ; echo "*/30 * * * * /opt/ds_agent/dsa_control -m >> /dev/null 2>&1") | sudo crontab -u plexity -
  fi
  #run this script every other hour
  (sudo crontab -u plexity -l ; echo "0 */2 * * * /opt/plexity/update.sh") | sudo crontab -u plexity -
  echo -e $(date +'%b %d %H:%M:%S') "Plexity crontab has been updated." | tee -a /var/log/plexity/$(date '+%Y%m%d').log
  sudo crontab -u plexity -l
}
#

#if a log file today already exists...
if [ -f /var/log/plexity/$(date '+%Y%m%d').log ]; then
  #if file contains "Logs sent"
  if grep -q "Logs sent" /var/log/plexity/$(date '+%Y%m%d').log; then
    exit
  else
    cat /var/log/plexity/$(date '+%Y%m%d').log | /opt/plexity/notify.sh
  fi
#if a log file for today does not already exist...
else 
  check-installed
  update-scripts
  update-cronjobs
  if [[ $dsagent == *"installed"* ]]; then
    sudo sudo yum -y -e 0 update -x 'kernel*'
    sudo cat /var/log/yum.log | grep "$(date +'%b %d')" >> /var/log/plexity/$(date '+%Y%m%d').log
    echo -e $(date +'%b %d %H:%M:%S')' Checked for updates to CentOS packages' >> /var/log/plexity/$(date '+%Y%m%d').log
    dskernel
  else
    sudo sudo yum -y -e 0 update
    sudo grep -v plexmediaserver /var/log/yum.log | grep "$(date +'%b %d %H')" >> /var/log/plexity/$(date '+%Y%m%d').log
  fi
  if [[ $plexmediaserver == *"installed"* ]]; then
    sudo /opt/plexity-plexupdate/plexupdate.sh
    sudo grep -v plexmediaserver /var/log/yum.log | grep "$(date +'%b %d')" >> /var/log/plexity/$(date '+%Y%m%d').log
    /opt/plexity-filebot/update-filebot.sh
  fi
  cat /var/log/plexity/$(date '+%Y%m%d').log | /opt/plexity/notify.sh
  echo -e $(date +'%b %d %H:%M:%S')' Logs sent' >> /var/log/plexity/$(date '+%Y%m%d').log
fi
