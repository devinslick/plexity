while read app; do
  if [[ ${app:0:1} == '*' ]];
  then
    /opt/plexity/$(echo $app| cut -d "*" -f 1)/setup.sh
  else
    sudo yum -y install $app
  fi
done < /var/plexity/desired.apps
