#!/bin/bash
#

#self update
git pull
#give other scripts in current directory execute permissions (others may have been added)
chmod +x *.sh
#ignore permissions changes when performing updates (git pull)
git config --global core.filemode false


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
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Complete/" -r --format "{n} - {y}" --output /mnt/files/Movies/
find /mnt/files/Complete/ -empty -type d -delete
find /mnt/files/Complete/
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Movies/" --output /mnt/share/Movies/ -non-strict -no-xattr
