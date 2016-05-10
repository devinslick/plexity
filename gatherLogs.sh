#!/bin/bash
cat /var/log/yum.log | grep "$today" | /opt/plexity/notify.sh

