#!/bin/bash
sudo /opt/plexity-plexupdate/plexupdate.sh
sudo grep plexmediaserver /var/log/yum.log | grep "$(date +'%b %d %H')" >> /var/log/plexity/$(date '+%Y%m%d').log