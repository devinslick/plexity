yum -y install git
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt 2> /dev/null
/opt/letsencrypt/letsencrypt-auto --agree-tos --keep --rsa-key-size 4096 --standalone certonly -m letsencrypt@devinslick.com -d home.devinslick.com
openssl pkcs12 -export -out /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/certificate.pfx -inkey /etc/letsencrypt/live/home.devinslick.com/privkey.pem -in /etc/letsencrypt/live/home.devinslick.com/fullchain.pem -certfile /etc/letsencrypt/live/home.devinslick.com/cert.pem

# Certificate renewal
# /opt/letsencrypt/letsencrypt-auto renew
