#!/bin/bash
#
git pull
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
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Complete/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output /mnt/files/TV\ Shows/ -non-strict
find /mnt/files/Complete/ -empty -type d -delete
find /mnt/files/Complete/
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/TV Shows/" --output "/mnt/share/TV Shows/"
