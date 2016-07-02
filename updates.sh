#!/bin/bash

plexmediaserver=$(rpm -qa | grep plexmediaserver)
deepsecurityagent=$(rpm -qa | grep ds_agent)

if [ ${#plexmediaserver} -gt 0 ];
then
  /opt/plexity/plexmediaserver/update.sh -a -C -d -s
fi

if [ ${#deepsecurityagent} -gt 0 ];
then
  yum -y -e 0 update -x 'kernel*'
  kernelResult=$(/opt/plexity/deepsecurityagent/updatekernel.sh)
else
  yum -y -e 0 update
fi

if rpm -qa | grep -qa VirtualBox;
then
  checkForKernelUpdate=$(tail -25 /var/log/yum.log | grep "$(date '+%b $d')" | grep "Installed: kernel")
  if [ ${#checkForKernelUpdate} -gt 0 ];
  then
    /sbin/rcvboxdrv stop
    yum -y install kernel-devel kernel-headers
    /sbin/rcvboxdrv setup
  fi
fi
