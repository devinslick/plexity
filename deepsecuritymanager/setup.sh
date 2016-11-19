Installing SQL server for linux....
curl https://packages.microsoft.com/config/rhel/7/mssql-server.repo > /etc/yum.repos.d/mssql-server.repo
yum install -y mssql-server
export SA_PASSWORD=localSApassword
/opt/mssql/bin/sqlservr-setup --accept-eula --set-sa-password
systemctl start mssql-server
systemctl enable mssql-server

#!/bin/bash
echo This script will setup a Deep Security Manager on CentOS 7.
yum -y install java-1.8.0-openjdk*
if [ -f /var/plexity/dsm.license ];
then
  license=$(cat /var/plexity/dsm.license)
else
  read -n 1 -p "Would you like to add your license key now? [y/n]: " installDSM
  if [ $installDSM = 'y' ];
  then
    echo -n "Enter your Deep Security Manager license key: "
    read -u license
      echo $license > /var/plexity/dsm.license
  else
    license=""
  fi
fi

if [ -f /var/plexity/dsm.user ];
then
  dsmuser=$(cat /var/plexity/dsm.user)
  dsmpass=$(cat /var/plexity/dsm.pass)
else
  read -n 1 -p "Would you like to configure a your username and password? [y/n]: " userpass
  if [ $userpass = 'y' ];
  then
    echo -n "Enter your admin username [default is masteradmin]: "
    read -u dsmuser
    echo $dsmuser > /var/plexity/dsm.user
    echo -n "Enter your admin password [default is masteradmin]: "
    read -u dsmpass
    echo $dsmpass > /var/plexity/dsm.pass
  else
    dsmuser="masteradmin"
    dsmpass="masteradmin"
  fi
fi

wget http://files.trendmicro.com/products/deepsecurity/9.6_SP1_P1/DeepSecurityManager/Manager-Linux-9.6.4064.x64.sh -O /tmp/dsmsetup.sh
echo "AddressAndPortsScreen.NewNode=True" > /tmp/install.config
echo "UpgradeVerification.Overwrite=False" >> /tmp/install.config
echo "LicenseScreen.License.-1=$license" >> /tmp/install.config
echo "DatabaseScreen.DatabaseType=Microsoft SQL Server" >> /tmp/install.config
echo "DatabaseScreen.Hostname=127.0.0.1" >> /tmp/install.config
echo "DatabaseScreen.DatabaseName=dsm" >> /tmp/install.config
echo "DatabaseScreen.Transport=TCP" >> /tmp/install.config
echo "DatabaseScreen.Username=sql_account_dsm" >> /tmp/install.config
echo "DatabaseScreen.Password=sql_account_pass" >> /tmp/install.config
echo "CredentialsScreen.Administrator.Username=$dsmuser" >> /tmp/install.config
echo "CredentialsScreen.Administrator.Password=$dsmpass" >> /tmp/install.config
echo "CredentialsScreen.UseStrongPasswords=False" >> /tmp/install.config
echo "SecurityUpdateScreen.UpdateComponents=True" >> /tmp/install.config
echo "SoftwareUpdateScreen.UpdateSoftware=True" >> /tmp/install.config
echo "RelayScreen.Install=False" >> /tmp/install.config
echo "SmartProtectionNetworkScreen.EnableFeedback=False" >> /tmp/install.config
chmod +x /tmp/dsmsetup.sh
/tmp/dsmsetup.sh -q -console -varfile /tmp/install.config
chkconfig dsm_s on
systemctl start dsm_s
echo "https://"$(hostname)":4119/SignIn.screen"
echo "Login using the username and password: $dsmuser:$dsmpass"
rm -rf /tmp/dsmsetup.sh
