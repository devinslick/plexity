#!/bin/bash

if [ ! -d "/media/files/Complete/" ]; then
  echo There are no completed downloads in /media/files/Complete/
  exit
fi

find /media/files/Complete/ -type f -size -75M -exec rm {} +
mkdir -p /media/files/Queue/
mkdir -p /media/files/Movies/

echo Checking for 1080p movies...
find /media/files/Complete/ -iname "*1080*" -type f -exec mv {} /media/files/Queue/ \; >/dev/null
sudo /opt/plexity-filebot/filebot.sh -rename /media/files/Queue/ -r --format "{n} - {y} - 1080p" --output "/media/files/Movies/" -non-strict
find /media/files/Complete/ -empty -type d -delete

if [ -d "/media/files/Complete/" ]; then
  echo More movies exist, checking for 720p...
  find /media/files/Complete/ -iname "*720*" -type f -exec mv {} /media/files/Queue/ \; >/dev/null
  sudo /opt/plexity-filebot/filebot.sh -rename /media/files/Queue/ -r --format "{n} - {y} - 720p" --output "/media/files/Movies/" -non-strict
  find /media/files/Complete/ -empty -type d -delete
fi

if [ -d "/media/files/Complete/" ]; then
  echo Checking for 480p movies...
  find /media/files/Complete/ -name "*480*" -type f -exec mv {} /media/files/Queue/ \; >/dev/null
  sudo /opt/plexity-filebot/filebot.sh -rename /media/files/Queue/ -r --format "{n} - {y} - 480p" --output "/media/files/Movies/" -non-strict
  find /media/files/Complete/ -empty -type d -delete
fi

if [ -d "/media/files/Complete/" ]; then
  echo Checking for 360p movies...
  find /media/files/Complete/ -name "*360p*" -type f -exec mv {} /media/files/Queue/ \; >/dev/null
  sudo /opt/plexity-filebot/filebot.sh -rename /media/files/Queue/ -r --format "{n} - {y} - 480p" --output "/media/files/Movies/" -non-strict
  find /media/files/Complete/ -empty -type d -delete
fi



find /media/files/Queue/ -empty -type d -delete
find /media/files/Complete/ -empty -type d -delete

echo Done with searching for resolution-named movies.  Checking for movies without resolution in the filename...
if [ -d "/media/files/Complete/" ]; then
  for movie in $(find "/media/files/Complete/" -iname '*' -type f); do 
    echo Checking resolution of $movie
    height=$(ffprobe -v quiet -print_format json -show_format -show_streams "$movie"  | grep height | grep -oE "[[:digit:]]{1,}" | head -n 1)
    if [ $height -ge 800 ]; then
      echo 1080p
      mv $movie "/media/files/Queue/"
      sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/" -r --format "{n} - {y} - 1080p" --output "/media/files/Movies/" -non-strict
    elif [ $height -ge 530 ]; then
      echo 720p
      mv $movie /media/files/Queue/
      sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/" -r --format "{n} - {y} - 720p" --output "/media/files/Movies/" -non-strict
    elif [ $height -ge 390 ]; then
      echo 480p
      mv $movie /media/files/Queue/
      sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/" -r --format "{n} - {y} - 480p" --output "/media/files/Movies/" -non-strict
    elif [ $height -ge 340 ]; then
      echo 360p
      mv $movie /media/files/Queue/
      sudo /opt/plexity-filebot/filebot.sh -rename "/media/files/Queue/" -r --format "{n} - {y} - 360p" --output "/media/files/Movies/" -non-strict
    fi
  done

  echo Moving files from /media/files/Movies to /media/share/Movies...
  ls /media/files/Movies
  echo ...
  mv /media/files/Movies/* /media/share/Movies/

  find "/media/files/Queue/" -empty -type d -delete
  find "/media/files/Complete/" -empty -type d -delete
  find "/media/files/Movies/" -empty -type d -delete
  echo Complete
fi

if [ -d "/media/files/Movies/" ]; then
  echo Moving files from /media/files/Movies to /media/share/Movies...
  ls /media/files/Movies
  echo ...
  mv /media/files/Movies/* /media/share/Movies/
  find "/media/files/Queue/" -empty -type d -delete >/dev/null
  find "/media/files/Complete/" -empty -type d -delete >/dev/null
  find "/media/files/Movies/" -empty -type d -delete >/dev/null
  echo Complete
fi
#echo Complete.
