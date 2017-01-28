email=$(cat /var/plexity/ssl.emailaddress)
if [ ${#email} -lt 6 ]
then
  echo "A valid email address was not found in /var/plexity/ssl.emailaddress"
  exit 
fi

name=$(cat /var/plexity/ssl.hostname)
if [ ${#name} -lt 6 ]
then
  echo "A valid FQDN was not found in /var/plexity/ssl.hostname"
  exit 
fi

systemctl stop httpd
/opt/letsencrypt/letsencrypt-auto --agree-tos --keep --rsa-key-size 4096 --standalone certonly -m $email -d $name

#plex
openssl pkcs12 -export -in /etc/letsencrypt/live/$name/fullchain.pem -inkey /etc/letsencrypt/live/$name/privkey.pem -out /var/lib/plexmediaserver/archive2.pfx -name $name -passout pass:
systemctl restart plexmediaserver

#plexpy
cp /etc/letsencrypt/live/$name/fullchain.pem /opt/plexpy/fullchain.pem
cp /etc/letsencrypt/live/$name/privkey.pem /opt/plexpy/privkey.pem
systemctl restart plexpy

#DSM
genkey=$(cat /opt/dsm/installfiles/genkey)
genkey=$(echo $genkey | grep -o -P '(?<=-keypass ).*(?= -validity)')
rm -rf /opt/dsm/.keystore
openssl pkcs12 -export -in /etc/letsencrypt/live/$name/cert.pem -inkey /etc/letsencrypt/live/$name/privkey.pem -out /etc/letsencrypt/live/$name/cert_and_key.p12 -name tomcat -CAfile /etc/letsencrypt/live/$name/chain.pem -caname root -password pass:
keytool -importkeystore -deststorepass $genkey -destkeypass $genkey -destkeystore /opt/dsm/.keystore -srckeystore /etc/letsencrypt/live/$name/cert_and_key.p12 -srcstoretype PKCS12 -srcstorepass "" -alias tomcat
keytool -import -trustcacerts -alias root -file /etc/letsencrypt/live/$name/chain.pem -keystore /opt/dsm/.keystore -storepass $genkey
systemctl restart dsm_s
systemctl start httpd
