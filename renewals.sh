echo "Renewing certificate...."
/opt/letsencrypt/letsencrypt-auto renew
echo "Importing into PlexPy..."
cp /etc/letsencrypt/live/home.devinslick.com/fullchain.pem /opt/plexpy/fullchain.pem
cp /etc/letsencrypt/live/home.devinslick.com/privkey.pem /opt/plexpy/privkey.pem
systemctl restart plexpy
echo "Importing into Plex..."
openssl pkcs12 -export -out "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/certificate.pfx" -inkey "/etc/letsencrypt/live/home.devinslick.com/privkey.pem" -in "/etc/letsencrypt/live/home.devinslick.com/fullchain.pem" -certfile "/etc/letsencrypt/live/home.devinslick.com/cert.pem"
systemctl restart plexmediaserver
