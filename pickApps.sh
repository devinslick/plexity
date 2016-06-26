read -n 1 -p "Plex Media Server? [y/n]: " plexmediaserver
if [ $plexmediaserver = 'y' ];
then
  echo '*plexmediaserver' >> /var/plexity/desired.apps
  echo "\n"
else
  sed -n -i '/*plexmediaserver/!p' /var/plexity/desired.apps
  echo "\n"
fi

read -n 1 -p "Transmission Server? [y/n]: " transmission
if [ $transmission = 'y' ];
then
  echo transmission >> /var/plexity/desired.apps
  echo "\n"
else
  sed -n -i '/transmission/!p' /var/plexity/desired.apps
  echo "\n"
fi

read -n 1 -p "Deep Security Manager? [y/n]: " deepsecuritymanager
if [ $deepsecuritymanager = 'y' ];
then
  echo '*deepsecuritymanager' >> /var/plexity/desired.apps
  echo "\n"
else
  sed -n -i '/*deepsecuritymanager/!p' /var/plexity/desired.apps
  echo "\n"
fi

read -n 1 -p "Deep Security Agent? [y/n]: " deepsecuritymanager
if [ $deepsecurityagent = 'y' ];
then
  echo '*deepsecurityagent' >> /var/plexity/desired.apps
  echo "\n"
else
  sed -n -i '/*deepsecurityagent/!p' /var/plexity/desired.apps
  echo "\n"
fi

read -n 1 -p "HandBrake video editor? [y/n]: " handbrake
if [ $handbrake = 'y' ];
then
  echo 'HandBrake-{gui,cli}' >> /var/plexity/desired.apps
  echo "\n"
else
  sed -n -i '/HandBrake-{gui,cli}/!p' /var/plexity/desired.apps
  echo "\n"
fi

read -n 1 -p "SMPlayer, VLC, and codecs for media playback? [y/n]: " players
if [ $players = 'y' ];
then
  echo 'vlc' >> /var/plexity/desired.apps
  echo 'smplayer' >> /var/plexity/desired.apps
  echo 'libdvdcss gstreamer*' >> /var/plexity/desired.apps
  echo "\n"
else
  sed -n -i '/vlc/!p' /var/plexity/desired.apps
  sed -n -i '/smplayer/!p' /var/plexity/desired.apps
  sed -n -i '/libdvdcss gstreamer*/!p' /var/plexity/desired.apps
  echo "\n"
fi

