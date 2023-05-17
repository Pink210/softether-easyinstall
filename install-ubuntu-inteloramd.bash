#!/bin/bash
# Define console colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Execute as sudo
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear

# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nThis script will remove SoftEther if it has been previously installed. Please backup your config file via the GUI manager or copy it from /opt/vpnserver/ if you are upgrading.\n\nThis will download and compile SoftEther VPN on your server. Are you sure you want to continue? [y/N] ' response
case $response in
[yY][eE][sS]|[yY])

# REMOVE PREVIOUS INSTALL
# Check for SE install folder
if [ -d "/opt/vpnserver" ]; then
  rm -rf /opt/vpnserver > /dev/null 2>&1
fi

if [ -d "/tmp/softether-autoinstall" ]; then
  rm -rf /tmp/softether-autoinstall > /dev/null 2>&1
fi

# Check for init script
if
  [ -f "/etc/init.d/vpnserver" ]; then rm /etc/init.d/vpnserver;
fi

# Remove vpnserver from systemd
update-rc.d vpnserver remove > /dev/null 2>&1

# Create working directory
mkdir -p /tmp/softether-autoinstall
cd /tmp/softether-autoinstall

# Perform apt update & install necessary software
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y && sudo apt install net-tools && sudo apt install ncat

# Install build-essential and checkinstall
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
echo  "Checking for build-essential: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "build-essential not installed. Installing now."
  sudo apt install -y build-essential
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' checkinstall|grep "install ok installed")
echo "Checking for checkinstall: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "checkinstall not installed. Installing now."
  sudo apt install -y checkinstall
fi

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' build-essential|grep "install ok installed")
echo  "Checking for build-essential: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "build-essential is still not installed. Possible problem with apt? Exiting."
  exit 1
fi

#install dependency
sudo apt install gcc binutils gzip libreadline-dev libssl-dev libncurses5-dev libncursesw5-dev libpthread-stubs0-dev

# Download SoftEther | Version 4.41 | Build 9787
printf "\nDownloading release: ${RED}4.34 RTM${NC} | Build ${RED}9745${NC}\n\n"
wget https://www.softether-download.com/files/softether/v4.41-9787-rtm-2023.03.14-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz
tar xvf softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz
cd vpnserver
apt install make -y
make
cd ..
sudo mv vpnserver /opt/softether
sudo /opt/softether/vpnserver start
sudo /opt/softether/vpnserver stop
#Openig port
printf "\Openig port"
sudo ufw allow 22
sudo ufw allow 53
sudo ufw allow 2280
sudo ufw allow 443
sudo ufw allow 80
sudo ufw allow 992
sudo ufw allow 1194
sudo ufw allow 2080
sudo ufw allow 5555
sudo ufw allow 4500
sudo ufw allow 1701
sudo ufw allow 500
sudo ufw allow 8280
sudo ufw allow 500,4500,8280,53/udp

echo 1 > /proc/sys/net/ipv4/ip_forward
cat /proc/sys/net/ipv4/ip_forward
done
esac
