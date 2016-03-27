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

find /mnt/files/Complete/ -type f -iname "*.sfv" -exec mv {} /mnt/files/Queue/Compressed/ \; >/dev/null
find /mnt/files/Complete/ -type f -iname "*.rar" -exec mv {} /mnt/files/Queue/Compressed/ \; >/dev/null
find /mnt/files/Complete/ -type f -iname "*.r[0-9][0-9]" -exec mv {} /mnt/files/Queue/Compressed/ \; >/dev/null
unrar x /mnt/files/Queue/Compressed/*.rar /mnt/files/Complete > /dev/null
rm -rf /mnt/files/Queue/Compressed

find /mnt/files/Complete/ -type f -size -40M -exec mv {} /mnt/files/Trash/ \; >/dev/null
find /mnt/files/Complete/ -type f -size -200M -iname "*sample*" -exec mv {} /mnt/files/Trash/ \; >/dev/null
find /mnt/files/Complete/ -type f -size -500M -exec mv {} /mnt/files/Queue/TV/ \; >/dev/null
find /mnt/files/Complete/ -type f -size +500M -exec mv {} /mnt/files/Queue/Movies/ \; >/dev/null

find /mnt/files/Queue/ -empty -type d -delete
find /mnt/files/Complete/ -empty -type d -delete

if [ -d "/mnt/files/Queue/Movies/" ]; then
  echo Identifying Movies...
  find "/mnt/files/Queue/Movies/"
  echo ...
  /opt/plexity-filebot/filebot.sh -script fn:xattr --action clear "/mnt/files/Queue/Movies/" >/dev/null
  /opt/plexity-filebot/filebot.sh -rename "/mnt/files/Queue/Movies/" -r --format "{n} ({y})" --output "/mnt/files/Movies/" -non-strict
  echo Moving Movies...
  ls /mnt/files/Movies
  echo ...
  mv -n /mnt/files/Movies/* /mnt/share/Movies/ &> /dev/null
fi

if [ -d "/mnt/files/Queue/TV/" ]; then
  echo Identifying TV Shows...
  find "/mnt/files/Queue/TV/"
  echo ...
  /opt/plexity-filebot/filebot.sh -script fn:xattr --action clear "/mnt/files/Queue/TV/" >/dev/null
  /opt/plexity-filebot/filebot.sh -rename "/mnt/files/Queue/TV/" -r --format "{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/mnt/files/TV/" -non-strict
  echo Moving TV Shows...
  ls /mnt/files/TV
  echo ...
  /opt/plexity-filebot/filebot.sh -rename "/mnt/files/TV/" -r --format "{n}/Season {s}/{n} - S{s.pad(2)}E{e.pad(2)} - {t}" --output "/mnt/share/TV Shows/" -non-strict -no-xattr
fi
find "/mnt/files/Movies/" -empty -type d -delete
find "/mnt/files/TV/" -empty -type d -delete
find /mnt/files/Queue/ -empty -type d -delete
echo Complete!
