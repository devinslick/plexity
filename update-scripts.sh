#!/bin/bash
cd /opt/plexity
git reset HEAD > /dev/null 2>&1
git checkout -- . > /dev/null 2>&1
echo "Updating Plexity from Github repository..."
OUTPUT="$(git pull -f)"

if [[ $OUTPUT == *"Already up-to-date"* ]]
then
   echo $(date +'%b %d %H:%m:%M') " Plexity script update is already up to date" | tee -a /var/log/plexity/today.log
else
   echo $(date +'%b %d %H:%m:%M') " Plexity script update complete!" | tee -a /var/log/plexity/today.log
fi

