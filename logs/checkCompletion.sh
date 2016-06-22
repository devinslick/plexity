#!/bin/bash
if [ -f /var/log/plexity/$(date '+%Y%m%d').log ];
  #log exists
  if grep -q "Logs sent" /var/log/plexity/$(date '+%Y%m%d').log; then
    #log exists and was sent
    exit
  else
    #log exists but was not sent
    cat /var/log/plexity/$(date '+%Y%m%d').log | /opt/plexity/notify.sh
  fi
else
  #log does not exist, rerun tasks
  /opt/plexity/updates.sh
  sleep(60)
fi
