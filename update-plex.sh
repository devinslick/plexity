#!/bin/bash
sudo /opt/plexity-plexupdate/plexupdate.sh
grep plexmediaserver /var/log/yum.log | grep "$(date +'%b %d %H')" >> /var/log/plexity/today.log
