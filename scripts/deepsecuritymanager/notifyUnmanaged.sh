numberUnmanaged = $(/opt/plexity/scripts/deepsecuritymanager/countUnmanaged.sh)
if [ $numberUnmanaged >= 0 ];
then
  echo $numberUnmanaged " are unmanaged"
else
  echo "All are managed"
fi
