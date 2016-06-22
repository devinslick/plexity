numberUnmanaged=$(/opt/plexity/scripts/deepsecuritymanager/countUnmanaged.sh)
if [ $numberUnmanaged -gt "0" ];
then
  #There are unmanaged agents in the Deep Security Manager"
  echo $numberUnmanaged
else
  #All are managed
  /opt/plexity/scripts/deepsecuritymanager/getUnmanaged.sh
fi
