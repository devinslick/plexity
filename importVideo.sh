#!/bin/bash

if [ ! -d "/mnt/files/Complete/" ]; then
  echo There are no completed downloads in /mnt/files/Complete/
  exit
fi

mkdir -p /mnt/files/Queue/TV/
mkdir -p /mnt/files/Queue/Movies/
mkdir -p /mnt/files/Queue/Compressed/
mkdir -p /mnt/files/Trash/
mkdir -p /mnt/files/Movies/
mkdir -p /mnt/files/TV/

echo "Looking for compresed files..."
find /mnt/files/Complete/ -type f -iname "*.sfv" -exec mv {} /mnt/files/Queue/Compressed/ \; >/dev/null
find /mnt/files/Complete/ -type f -iname "*.rar" -exec mv {} /mnt/files/Queue/Compressed/ \; >/dev/null
find /mnt/files/Complete/ -type f -iname "*.r[0-9][0-9]" -exec mv {} /mnt/files/Queue/Compressed/ \; >/dev/null
unrar x /mnt/files/Queue/Compressed/*.rar /mnt/files/Complete > /dev/null
rm -rf /mnt/files/Queue/Compressed

find /mnt/files/Complete/ -type f -size -40M -exec mv {} /mnt/files/Trash/ \; >/dev/null
find /mnt/files/Complete/ -type f -size -200M -iname "*sample*" -exec mv {} /mnt/files/Trash/ \; >/dev/null
find /mnt/files/Complete/ -type f -size -500M -exec mv {} /mnt/files/Queue/TV/ \; >/dev/null
find /mnt/files/Complete/ -type f -size +500M -exec mv {} /mnt/files/Queue/Movies/ \; >/dev/null

sudo /root/scripts/filebot/filebot.sh -script fn:xattr --action clear "/mnt/files/Queue/TV/"
sudo /root/scripts/filebot/filebot.sh -script fn:xattr --action clear "/mnt/files/Queue/Movies/"
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/TV/" -r --format "{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/mnt/files/TV/" -non-strict
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/Queue/Movies/" -r --format "{n} ({y})" --output "/mnt/files/Movies/" -non-strict


find /mnt/files/Queue/ -empty -type d -delete
find /mnt/files/Complete/ -empty -type d -delete

echo Moving files from /mnt/files/Movies to /mnt/share/Movies...
ls /mnt/files/Movies
echo ...
mv -n /mnt/files/Movies/* /mnt/share/Movies/ &> /dev/null
find "/mnt/files/Movies/" -empty -type d -delete
echo Complete

echo Moving files from /mnt/files/TV to /mnt/share/TV Shows...
ls /mnt/files/TV
echo ...
sudo /root/scripts/filebot/filebot.sh -rename "/mnt/files/TV/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/mnt/share/TV Shows/" -non-strict -no-xattr
find "/mnt/files/TV/" -empty -type d -delete

#   Removing this section while I work on automatically decompressing archives.
#echo "Checking /mnt/files/Trash for compressed files..."
#if [ -f /mnt/files/Trash/*.zip ] ||  [ -f /mnt/files/Trash/*.rar ] ||  [ -f *.001 ]; then
#  echo "Compressed files were found.  Please move or delete these so automatic trash cleanup can continue."
#else
#  echo "Cleaning /mnt/files/Trash..."
#  /root/scripts/filebot/filebot.sh -script fn:cleaner /mnt/files/Trash --def root=y
#fi

echo Complete
