#!/bin/bash
echo "This script is intended to configure Plexity on a new computer."  
echo "At the moment it will add users and install applications, though the goal is to separate these into their own tasks."

echo "Creating service account..."
  adduser -g wheel plexity
  echo plexity:$(date +%s | sha256sum | base64 | head -c 32) | chpasswd
  sed -i 's/Defaults:root !requiretty/#Defaults:root !requiretty/g' /etc/sudoers /etc/sudoers
  sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers /etc/sudoers
  sed -i 's/root    ALL=(ALL)       ALL/%wheel    ALL=(ALL)       ALL/g' /etc/sudoers /etc/sudoers
  sed -i 's/# %wheel/%wheel/g' /etc/sudoers /etc/sudoers

echo "Checking for related applications..."
  deepsecurityagent=$(rpm -qa | grep ds_agent)

echo "Creating crontab..."

echo "0 2 * * * /opt/plexity/updates.sh" | sudo crontab -u plexity -
if [ ${#deepsecurityagent} -gt 0 ];
then
  (sudo crontab -u plexity -l ; echo "*/30 * * * * /opt/ds_agent/dsa_control -m &> /dev/null") | sudo crontab -u plexity -
fi
