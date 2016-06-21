/opt/plexity/scripts/deepsecuritymanager/setup.sh
systemctl stop dsm_s
genkey=$(cat /opt/dsm/installfiles/genkey)
genkey=$(echo $genkey | grep -o -P '(?<=-keypass ).*(?= -validity)')
keytool -delete -alias root -storepass $genkey -keystore /root/.keystore -noprompt
keytool -delete -alias tomcat -storepass $genkey -keystore /root/.keystore -noprompt

openssl pkcs12 -export -in /etc/letsencrypt/live/home.devinslick.com/cert.pem -inkey /etc/letsencrypt/live/home.devinslick.com/privkey.pem -out /etc/letsencrypt/live/home.devinslick.com/cert_and_key.p12 -name tomcat -CAfile /etc/letsencrypt/live/home.devinslick.com/chain.pem -caname root -password pass:$genkey

keytool -importkeystore -deststorepass $genkey -destkeypass $genkey -destkeystore /etc/letsencrypt/live/home.devinslick.com/MyDSKeyStore.jks -srckeystore /etc/letsencrypt/live/home.devinslick.com/cert_and_key.p12 -srcstoretype PKCS12 -srcstorepass $genkey -alias tomcat

keytool -import -trustcacerts -alias root -file /etc/letsencrypt/live/home.devinslick.com/chain.pem -keystore /etc/letsencrypt/live/home.devinslick.com/MyDSKeyStore.jks -storepass $genkey

mv /opt/dsm/.keystore /opt/dsm/.keystore-orig
cp /etc/letsencrypt/live/home.devinslick.com/MyDSKeyStore.jks /opt/dsm/.keystore
systemctl start dsm_s
