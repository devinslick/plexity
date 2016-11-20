#!/bin/sh
domain="home.devinslick.com"
genkey=$(cat /opt/dsm/installfiles/genkey)
genkey=$(echo $genkey | grep -o -P '(?<=-keypass ).*(?= -validity)')
pemsdir="/etc/letsencrypt/live/$domain"
pfxspath="/etc/letsencrypt/live/$domain/pfx"
passfile="/opt/dsm/keypass.txt"
mkdir -p $pfxspath
echo $genkey > $passfile
for cnvifull in `find "${pemsdir}" -name 'cert*.pem' -o -name '*chain*.pem'`
do
  cnvifile=${cnvifull##*/}
  cnvinum=`echo ${cnvifile%.*} | sed -e "s#[cert|chain|fullchain]##g"`
  cnvipkey="${cnvifull%/*}/privkey${cnvinum}.pem"
  cnvopem=`echo ${cnvifull} | sed -e "s#${pemsdir}#${pfxspath}#g"`
  cnvofull="${cnvopem%.*}.pfx"
  echo "- :-) ->"
  echo "-in    ${cnvifull}"
  echo "-inkey ${cnvipkey}"
  echo "-out   ${cnvofull}"
  mkdir -p ${cnvofull%/*}
  openssl pkcs12 \
    -export \
    -in ${cnvifull} \
    -inkey ${cnvipkey} \
    -out ${cnvofull} \
    -password pass:$genkey
done
#backup previous DSM keystore
mkdir /opt/dsm/Backupkeystore 2&> /dev/null
cp -n /opt/dsm/.keystore /opt/dsm/Backupkeystore/
rm -rf /opt/dsm/.keystore

#create new keystore file
echo $genkey|keytool -importkeystore -destkeystore /opt/dsm/mykeystore.ks -srckeystore /etc/letsencrypt/live/home.devinslick.com/pfx/cert.pfx -srcstoretype pkcs12 -deststoretype JKS -deststorepass pass:$genkey

#restarting Deep Security Manager...
systemctl restart dsm_s
