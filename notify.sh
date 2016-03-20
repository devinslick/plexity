#!/bin/bash
URL="https://api.pushover.net/1/messages.json"
PUSHTITLE="Plexity - "$HOSTNAME
EMAILSUBJECT="plexity@"$HOSTNAME
PRIORITY=1
MESSAGE=$*
if [ ${#MESSAGE} == 0 ]
then
   MESSAGE=$(cat)
fi
if [ -f /etc/pushover.user.key ]
then # if user key has been defined
   if [ -f /etc/pushover.api.key ] # and user key has been defined
   then  # read those files to variable, take action
      APP_KEY=$(cat /etc/pushover.api.key)  
      USER_KEY=$(cat /etc/pushover.user.key)
      RESPONSE=$(curl -s --data token=$APP_KEY --data user=$USER_KEY --data-urlencode title="$PUSHTITLE" --data priority=$PRIORITY --data-urlencode message="$MESSAGE" $URL)
   else # if user has been defined but not api
      echo "Warning: Pushover user key was defined at /etc/pushover.user.key but api key (/etc/pushover.api.key) was missing"
      if [ -f /etc/emailaddress ]
      then
         logger "Plexity did not have a Pushover API key defined, falling back to email notification"
         echo $MESSAGE | /usr/bin/mailx -E -r "plexity"@$(cat /etc/hostname) -s $EMAILSUBJECT $(cat /etc/emailaddress)
      else
         logger "The Pushover User key was defined but not an API key or email address."
         logger "Assuming that the Pushover User key should be used as an email address: "$(cat /etc/pushover.user.key)"@api.pushover.net"
         echo $MESSAGE | /usr/bin/mailx -E -r "plexity"@$(cat /etc/hostname) -s $EMAILSUBJECT $(cat /etc/pushover.user.key)"@api.pushover.net"
      fi
   fi
else # failed the first test, no pushover user key defined.
   if [ -f /etc/emailaddress ]
      then
         echo $MESSAGE | /usr/bin/mailx -E -r "plexity"@$(cat /etc/hostname) -s $EMAILSUBJECT $(cat /etc/emailaddress)
      else
         logger "Plexity was unable to use Pushover or send email.  Please read Plexity documentation."
   fi
fi

exit 0;
