#!/bin/bash
echo "Updating CentOS packages on "$HOSTNAME"..."
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
echo -e $(date +'%b %d %H:%M:%S')' Checked for updates to CentOS packages' >> /var/log/plexity/$(date '+%Y%m%d').log
if [[ $dsagent == *"installed"* ]]
then
   echo "Skipping kernel updates since the Deep Security Agent is installed"
   sudo sudo yum -y -e 0 update -x 'kernel*'
else
   sudo sudo yum -y -e 0 update
fi
sudo grep -v plexmediaserver /var/log/yum.log | grep "$(date +'%b %d %H')" >> /var/log/plexity/$(date '+%Y%m%d').log
