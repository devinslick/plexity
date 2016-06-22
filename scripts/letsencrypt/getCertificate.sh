email=$(cat /var/plexity/ssl.emailaddress)
if [ ${#email} -lt 6 ]
then
  echo "A valid email address was not found in /var/plexity/ssl.emailaddress"
  exit 
fi

name=$(cat /var/plexity/ssl.hostname)
if [ ${#name} -lt 6 ]
then
  echo "A valid FQDN was not found in /var/plexity/ssl.emailaddress"
  exit 
fi
/opt/letsencrypt/letsencrypt-auto --agree-tos --keep --rsa-key-size 4096 --standalone certonly -m $email -d $name --test-cert
