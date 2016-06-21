/opt/letsencrypt/letsencrypt-auto --agree-tos --keep --rsa-key-size 4096 --standalone certonly -m $(cat /var/plexity/ssl.emailaddress) -d $(hostname)
