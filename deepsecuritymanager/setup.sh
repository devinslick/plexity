#!/bin/bash
echo This script will setup to setup a Deep Security Manager on CentOS 7.
yum -y install java-1.8.0-openjdk*
if [ -f /var/plexity/dsm.key ];
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
  license=$(cat /var/plexity/dsm.pass)
else
  read -n 1 -p "Would you like to configure a your username, password, and license now? [y/n]: " userpasslicense
  if [ $userpasslicense = 'y' ];
  then
    echo -n "Enter your admin username [default is masteradmin]: "
    read -u admin
    echo $admin > /var/plexity/dsm.user
    echo -n "Enter your admin password [default is masteradmin]: "
    read -u pass
    echo $pass > /var/plexity/dsm.pass
    echo -n "Enter your license key: "
    read -u license
    echo $license > /var/plexity/dsm.license
  else
    admin="masteradmin"
    pass="masteradmin"
  fi
fi

wget http://files.trendmicro.com/products/deepsecurity/en/9.6/9.6_ServicePack1/Manager-Linux-9.6.4000.x64.sh -O /tmp/dsmsetup.sh --quiet 
echo "AddressAndPortsScreen.NewNode=True" > /tmp/install.config
echo "UpgradeVerification.Overwrite=False" >> /tmp/install.config
echo "LicenseScreen.License.-1=$license" >> /tmp/install.config
echo "DatabaseScreen.DatabaseType=Embedded" >> /tmp/install.config
echo "CredentialsScreen.Administrator.Username=$admin" >> /tmp/install.config
echo "CredentialsScreen.Administrator.Password=$pass" >> /tmp/install.config
echo "CredentialsScreen.UseStrongPasswords=False" >> /tmp/install.config
echo "SecurityUpdateScreen.UpdateComponents=True" >> /tmp/install.config
echo "SoftwareUpdateScreen.UpdateSoftware=True" >> /tmp/install.config
cho "RelayScreen.Install=False" >> /tmp/install.config
echo "SmartProtectionNetworkScreen.EnableFeedback=False" >> /tmp/install.config
chmod +x /tmp/dsmsetup.sh
/tmp/dsmsetup.sh -q -console -varfile /tmp/install.config
chkconfig dsm_s on
systemctl start dsm_s
echo "https://"$(hostname)":4119/SignIn.screen"
echo "Login using the default username and password: masteradmin:masteradmin" 
