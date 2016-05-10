#!/bin/bash
today=$(date +'%b %d')
cat /var/log/yum.log | grep "$today" >> /var/log/plexity/today.lo

