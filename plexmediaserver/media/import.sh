#!/bin/bash

if [ ! -d "/media/files/Complete/" ]; then
  echo There are no completed downloads in /media/files/Complete/
  exit
fi

mkdir -p /media/files/Queue/TV/
mkdir -p /media/files/Queue/Movies/
mkdir -p /media/files/Queue/Compressed/
mkdir -p /media/files/Trash/
mkdir -p /media/files/Movies/
mkdir -p /media/files/TV/

echo "Looking for compresed files..."
find /media/files/Complete/ -type f -iname "*.sfv" -exec mv {} /media/files/Queue/Compressed/ \; >/dev/null
find /media/files/Complete/ -type f -iname "*.rar" -exec mv {} /media/files/Queue/Compressed/ \; >/dev/null
find /media/files/Complete/ -type f -iname "*.r[0-9][0-9]" -exec mv {} /media/files/Queue/Compressed/ \; >/dev/null
unrar x /media/files/Queue/Compressed/*.rar /media/files/Complete > /dev/null
rm -rf /media/files/Queue/Compressed

find /media/files/Complete/ -type f -iname "*.sfv" -exec mv {} /media/files/Queue/Compressed/ \; >/dev/null
find /media/files/Complete/ -type f -iname "*.rar" -exec mv {} /media/files/Queue/Compressed/ \; >/dev/null
find /media/files/Complete/ -type f -iname "*.r[0-9][0-9]" -exec mv {} /media/files/Queue/Compressed/ \; >/dev/null
unrar x /media/files/Queue/Compressed/*.rar /media/files/Complete > /dev/null
rm -rf /media/files/Queue/Compressed

find /media/files/Complete/ -type f -size -40M -exec mv {} /media/files/Trash/ \; >/dev/null
find /media/files/Complete/ -type f -size -200M -iname "*sample*" -exec mv {} /media/files/Trash/ \; >/dev/null
find /media/files/Complete/ -type f -size -600M -exec mv {} /media/files/Queue/TV/ \; >/dev/null
find /media/files/Complete/ -type f -size +600M -exec mv {} /media/files/Queue/Movies/ \; >/dev/null

sudo /opt/plexity-filebot/filebot.sh -script fn:xattr --action clear "/media/files/Queue/TV/"
sudo /opt/plexity-filebot/filebot.sh -script fn:xattr --action clear "/media/files/Queue/Movies/"
sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/TV/" -r --format "{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/media/files/TV/" -non-strict
sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/Movies/" -r --format "{n} ({y})" --output "/media/files/Movies/" -non-strict


find /media/files/Queue/ -empty -type d -delete
find /media/files/Complete/ -empty -type d -delete

echo Moving files from /media/files/Movies to /media/share/Movies...
ls /media/files/Movies
echo ...
mv -n /media/files/Movies/* /media/share/Movies/ &> /dev/null
find "/media/files/Movies/" -empty -type d -delete
echo Complete

echo Moving files from /media/files/TV to /media/share/TV Shows...
ls /media/files/TV
echo ...
sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/TV/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/media/share/TV Shows/" -non-strict -no-xattr
find "/media/files/TV/" -empty -type d -delete

echo Complete

find /media/files/Queue/ -empty -type d -delete
find /media/files/Complete/ -empty -type d -delete

if [ -d "/media/files/Queue/Movies/" ]; then
  echo Identifying Movies...
  find "/media/files/Queue/Movies/"
  echo ...
  /opt/plexity-filebot/filebot.sh -script fn:xattr --action clear "/media/files/Queue/Movies/" >/dev/null
  /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/Movies/" -r --format "{n} ({y})" --output "/media/files/Movies/" -non-strict
  echo Moving Movies...
  ls /media/files/Movies
  echo ...
  mv -n /media/files/Movies/* /media/share/Movies/ &> /dev/null
fi

if [ -d "/media/files/Queue/TV/" ]; then
  echo Identifying TV Shows...
  find "/media/files/Queue/TV/"
  echo ...
  /opt/plexity-filebot/filebot.sh -script fn:xattr --action clear "/media/files/Queue/TV/" >/dev/null
  /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/TV/" -r --format "{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/media/files/TV/" -non-strict
  echo Moving TV Shows...
  ls /media/files/TV
  echo ...
  /opt/plexity-filebot/filebot.sh -rename "/media/files/TV/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/media/share/TV Shows/" -non-strict -no-xattr
fi
find "/media/files/Movies/" -empty -type d -delete
find "/media/files/TV/" -empty -type d -delete
find /media/files/Queue/ -empty -type d -delete
echo Complete!
