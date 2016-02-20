#!/bin/bash

if [ ! -d "/mnt/files/Complete/" ]; then
  echo There are no completed downloads in /mnt/files/Complete/
  exit
fi

mkdir -p /mnt/files/Queue/TV/
mkdir -p /mnt/files/Queue/Movies/
mkdir -p /mnt/files/Trash/
mkdir -p /mnt/files/Movies/
mkdir -p /mnt/files/TV/

find /mnt/files/Complete/ -type f -size -40M -exec mv {} /mnt/files/Trash/ \; >/dev/null
find /mnt/files/Complete/ -type f -size -500M -exec mv {} /mnt/files/Queue/TV/ \; >/dev/null
find /mnt/files/Complete/ -type f -size +500M -exec mv {} /mnt/files/Queue/Movies/ \; >/dev/null

sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/TV/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/mnt/files/TV/" -non-strict
sudo /root/scripts/filebot/filebot.sh -rename /mnt/files/Queue/Movies/ -r --format "{n} ({y})" --output "/mnt/files/Movies/" -non-strict


find /mnt/files/Queue/ -empty -type d -delete
find /mnt/files/Complete/ -empty -type d -delete

echo Moving files from /mnt/files/Movies to /mnt/share/Movies...
ls /mnt/files/Movies
echo ...
mv --no-clobber /mnt/files/Movies/* /mnt/share/Movies/ &> /dev/null
find "/mnt/files/Movies/" -empty -type d -delete
echo Complete

echo Moving files from /mnt/files/TV to /mnt/share/TV Shows...
ls /mnt/files/TV
echo ...
mv --no-clobber /mnt/files/TV/* "/mnt/share/TV Shows/" &> /dev/null
find "/mnt/files/TV/" -empty -type d -delete

echo "Checking /mnt/files/Trash for compressed files..."
if [ -f *.zip ] ||  [ -f *.rar ] ||  [ -f *.001 ]; then
  echo "Compressed files were found.  Please move or delete these so automatic trash cleanup can continue."
else
  echo "Cleaning /mnt/files/Trash..."
  /root/scripts/filebot/filebot.sh -script fn:cleaner /mnt/files/Trash --def root=y
fi

echo Complete
