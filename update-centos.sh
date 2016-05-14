#!/bin/bash
echo "Updating CentOS packages on "$HOSTNAME"..."
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
if [[ $dsagent == *"installed"* ]]
then
   echo "Skipping kernel updates since the Deep Security Agent is installed"
   sudo yum -y -e 0 -x 'kernel*'
else
   sudo yum -y -e 0 update
fi
echo -e $(date +'%b %d %H:%m:%M')' Updating CentOS packages' >> /var/log/plexity/$(date '+%Y%m%d').log
