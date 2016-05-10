#!/bin/bash
echo "Updating CentOS packages on "$HOSTNAME"..."
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
if [[ $dsagent == *"installed"* ]]
then
   echo "Skipping kernel updates since the Deep Security Agent is installed"
   result=$(yum -y -e 0 -x 'kernel*' update)
else
   result=$(yum -y -e 0 update)
fi

echo -e $(date '+%Y%m%d%H%m')'\tUpdating CentOS packages' >> /var/plexity/$(date '+%Y%m%d').log

# if contains 'Error downloading packages:' then possible network connectivity issue

echo $result >> /var/plexity/$(date '+%Y%m%d').log
