#!/bin/bash
today=$(date +'%b %d')
cat /var/log/yum.log | grep "$today" >> /var/log/plexity/today.log
cat /var/log/plexity/today.log | /opt/plexity/notify.sh
mv /var/log/plexity/today.log /var/log/plexity/$(date +'%Y%m%d').log
