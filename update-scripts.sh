#!/bin/bash
cd /opt/plexity
git reset HEAD > /dev/null 2>&1
git checkout -- . > /dev/null 2>&1
echo "Updating Plexity from Github repository..."
OUTPUT="$(git pull -f)"

if [[ $OUTPUT == *"Already up-to-date"* ]]
then
   echo "No changes have been made to the repository, no update necessary."
else
   echo "Update complete!"
fi
