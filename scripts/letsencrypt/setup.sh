yum -y install git
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt 2> /dev/null
echo -n "Enter the email address to be associated with your certificate:"
read emailaddress
if [ ${#emailaddress} -gt 5 ]
then
   echo $emailaddress > /var/plexity/ssl.emailaddress
else
   echo "A valid email address was not entered.  This is needed to generate certificates"
fi

echo "Your hostname is $(hostname)"
read -n 1 -p "Do you want to use this for certificate generation?  Is this a public address and accessible on port 80? [y/n]: " useHostname
if [ $useHostname = 'y' ];
then
  echo $(hostname) > /var/plexity/ssl.hostname
else
  echo -n "Enter the address you'd like to use for certificates:"
  read newHostname
  if [ ${#newHostname} -ge 5 ]
  then
    echo $pushoverapi > /var/plexity/ssl.hostname
  fi
fi
