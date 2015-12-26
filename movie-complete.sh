#!/bin/bash
#

#run commands from path of scripts
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  exit 1  # fail
fi
cd $MY_PATH

#ignore permissions changes when performing updates (git pull)
git config --global core.filemode false

#self update
git pull

#give other scripts in current directory execute permissions (others may have been added)
chmod +x *.sh

#remove 'junk' files
find /mnt/files/Complete/ -type f -name '*.jpg' -delete
find /mnt/files/Complete/ -type f -name '*.jpeg' -delete
find /mnt/files/Complete/ -type f -name '*.txt' -delete
find /mnt/files/Complete/ -type f -name '*.srt' -delete
find /mnt/files/Complete/ -type f -name '*.smi' -delete
find /mnt/files/Complete/ -type f -name '*.idx' -delete
find /mnt/files/Complete/ -type f -name '*.sub' -delete
find /mnt/files/Complete/ -type f -name '*.nfo' -delete
find /mnt/files/Complete/ -type f -name 'RARBG.COM.mp4' -delete
find /mnt/files/Complete/ -type f -name 'sample.avi' -delete

#rename files and update metadata, move them from the import directory to staging
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Complete/" -r --format "{n} - {y}" --output /mnt/files/Movies/

#clean up empty folders in the staging directory
find /mnt/files/Complete/ -empty -type d -delete

#display remaining files in the staging directory in case filebot misses any
find /mnt/files/Complete/

#move files from staging to library
mv /mnt/files/Movies/* /mnt/share/Movies/
