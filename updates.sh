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
  /opt/plexity/deepsecurityagent/updatekernel.sh
else
  yum -y -e 0 update
fi
