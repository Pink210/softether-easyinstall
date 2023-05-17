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

# Perform apt update & install necessary software
sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y
sleep 5


# Install install net-tools
printf "\n${RED}install net-tools${NC}\n\n"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' net-tools|grep "install ok installed")
echo  "Checking for net-tools: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "net-tools not installed. Installing now."
  sudo apt install -y net-tools
fi
sleep 5
# Install install ncat
printf "\n${RED}install ncat${NC}\n\n"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ncat|grep "install ok installed")
echo  "Checking for ncat: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "ncat not installed. Installing now."
  sudo apt install -y ncat
fi
sleep 5
# Install install certbot
printf "\n${RED}install certbot${NC}\n\n"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' certbot|grep "install ok installed")
echo  "Checking for certbot: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "certbot not installed. Installing now."
  sudo apt install -y certbot
fi
sleep 5
#install dependency
sudo apt install -y gcc binutils gzip libreadline-dev libssl-dev libncurses5-dev libncursesw5-dev libpthread-stubs0-dev
sleep 5
# Download SoftEther | Version 4.41 | Build 9787
printf "\nDownloading release: ${RED}4.41 RTM${NC} | Build ${RED}9787${NC}\n\n"
wget https://www.softether-download.com/files/softether/v4.41-9787-rtm-2023.03.14-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz
sleep 5
tar xvf softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz
sleep 5
cd vpnserver
sleep 5
apt install make -y
sleep 10
make
sleep 5
cd ..
sleep 2
sudo mv vpnserver /opt/softether
sleep 2
sudo /opt/softether/vpnserver start
sleep 10
sudo /opt/softether/vpnserver stop
sleep 5
printf "\n${RED}Create the service file${NC}\n\n"
# Create the service file with the desired content
sudo tee /etc/systemd/system/softether-vpnserver.service > /dev/null << EOF
[Unit]
Description=SoftEther VPN server
After=network-online.target
After=dbus.service

[Service]
Type=forking
ExecStart=/opt/softether/vpnserver start
ExecReload=/bin/kill -HUP \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

# Reload the systemd daemon to recognize the new service
printf "\n${RED}daemon to recognize the new service${NC}\n\n"
sudo systemctl daemon-reload
sleep 2
# Enable the service to start on boot
printf "\n${RED}Enable the service to start on boot${NC}\n\n"
sudo systemctl enable softether-vpnserver.service
sleep 2
# Start the service
printf "\n${RED}Start the service${NC}\n\n"
sudo systemctl start softether-vpnserver.service
sleep 5
#12 enable IPv4 forwadring 
printf "\n${RED}enable IPv4 forwadring${NC}\n\n"
echo 1 > /proc/sys/net/ipv4/ip_forward
sleep 5
cat /proc/sys/net/ipv4/ip_forward
#Openig port

printf "\n${RED}Openig port${NC}\n\n"
sudo ufw allow 22
sleep 2
sudo ufw allow 53
sleep 2
sudo ufw allow 2280
sleep 2
sudo ufw allow 2380
sleep 2
sudo ufw allow 443
sleep 2
sudo ufw allow 80
sleep 2
sudo ufw allow 992
sleep 2
sudo ufw allow 1194
sleep 2
sudo ufw allow 2080
sleep 2
sudo ufw allow 5555
sleep 2
sudo ufw allow 4500
sleep 2
sudo ufw allow 1701
sleep 2
sudo ufw allow 500
sleep 2
sudo ufw allow 8280
sleep 2
sudo ufw allow 500,4500,8280,53/udp
sleep 15
reboot
esac
