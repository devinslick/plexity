#!/bin/bash
ls /var/plexity/*.camera | while read cameraURL; do
   echo "Processing file '$cameraURL'"
   mkdir -p /media/files/Security/$(basename $(ls $cameraURL | cut -d '.' -f1))/$(date '+%Y%m%d') 
   /bin/wget -O /media/files/Security/$(basename $(ls $cameraURL | cut -d '.' -f1))/$(date +"%Y%m%d")/$(date +"%Y-%m-%d-%H:%M:%S").jpg -x $(cat $cameraURL)
done
