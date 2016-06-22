wget http://files.trendmicro.com/products/deepsecurity/en/9.6/Agent-RedHat_EL7-9.6.2-5027.x86_64.zip -O /tmp/dsa.zip
unzip -n /tmp/dsa.zip -x *.dsp -d /tmp/dsa/
if [ ! -d "/opt/ds_agent" ];
then
  rpm -i /tmp/dsa/*.rpm
else
  rpm -U /tmp/dsa/*.rpm
fi
rm -rf /tmp/dsa*
