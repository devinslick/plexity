#!/bin/bash
echo "Updating CentOS packages on "$HOSTNAME"..."
dsagent=$(yum info ds_agent.x86_64 | grep "Repo        : installed")
if [[ $dsagent == *"installed"* ]]
then
   echo "Skipping kernel updates since the Deep Security Agent is installed"
   yum -y -e 0 -x 'kernel*' update
else
   yum -y -e 0 update
fi

