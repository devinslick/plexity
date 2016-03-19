#!/bin/bash
URL="https://api.pushover.net/1/messages.json"
TITLE="Plexity Alert"
PRIORITY=1
MESSAGE=$*
if [ ${#MESSAGE} == 0 ]
then
   MESSAGE=$(cat)
fi
if [ -f /etc/pushover.api.key ]
then # if api key has been defined
   if [ -f /etc/pushover.user.key ] # and user key has been defined
   then  # read those files to variable, take action
      APP_KEY=$(cat /etc/pushover.api.key)  
      USER_KEY=$(cat /etc/pushover.user.key)
      RESPONSE=$(curl -s --data token=$APP_KEY --data user=$USER_KEY --data-urlencode title="$TITLE" --data priority=$PRIORITY --data-urlencode message="$MESSAGE" $URL)
   else # if one has been defined but not the other
      echo "Error: Pushover API key was defined at /etc/pushover.api.key but user key (/etc/pushover.user.key) was missing"
      if [ -f /etc/emailaddress ]
      then
         logger "Plexity was unable to use Pushover API, falling back to email notification"
         echo $MESSAGE | /usr/bin/mailx -E -r plexity@$(cat /etc/hostname) -s $(cat /etc/hostname) $(cat /etc/emailaddress)
      else
         logger "Plexity was unable to use Pushover or send email.  Please read Plexity documentation."
      fi
   fi
else # failed the first test, no pushover api key defined.
   if [ -f /etc/emailaddress ]
      then
         echo $MESSAGE | /usr/bin/mailx -E -r plexity@$(cat /etc/hostname) -s $(cat /etc/hostname) $(cat /etc/emailaddress)
      else
         logger "Plexity was unable to use Pushover or send email.  Please read Plexity documentation."
   fi
fi

exit 0;
