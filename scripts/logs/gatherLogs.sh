#!/bin/bash
cat /var/log/plexity/$(date '+%Y%m%d').log | /opt/plexity/notify.sh
