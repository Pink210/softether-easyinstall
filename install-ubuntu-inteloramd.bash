#!/usr/bin/env bash
# colors
RED='\033[0;31m'
NC='\033[0m' # No Color
# Execute as sudo
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear
# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nThis script will remove SoftEther if it has been previously installed. Please backup your config file via the GUI manager or copy it from /opt/vpnserver/ if you are upgrading.\n\nThis will download and compile SoftEther VPN on your server. Are you sure you want to continue? [[y/N]] ' response
case "$response" in
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
systemctl disable vpnserver > /dev/null 2>&1

# Perform apt update & install necessary software
sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y
sleep 2


# Install install net-tools
printf "%sinstall net-tools%s" "$RED" "$NC"
PKG_OK=$(command -v net-tools)
echo  "Checking for net-tools: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "net-tools not installed. Installing now."
  sudo apt-get install -y net-tools
fi
sleep 2

# Install install ncat
printf "%sinstall ncat%s" "$RED" "$NC"
PKG_OK=$(command -v ncat)
echo  "Checking for ncat: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "ncat not installed. Installing now."
  sudo apt-get install -y ncat
fi
sleep 2

# Install install certbot
printf "%sinstall certbot%s" "$RED" "$NC"
PKG_OK=$(command -v certbot)
echo  "Checking for certbot: $PKG_OK"
if [ "" == "$PKG_OK" ]; then
  echo "certbot not installed. Installing now."
  sudo apt-get install -y certbot
fi
sleep 2

#install dependency
sudo apt install -y gcc binutils gzip libreadline-dev libssl-dev libncurses5-dev libncursesw5-dev libpthread-stubs0-dev || exit
sleep 2
# Download SoftEther | Version 4.41 | Build 9787
printf "%sDownloading release: 4.41 RTM | Build 9787%s" "$RED" "$NC"
wget https://www.softether-download.com/files/softether/v4.41-9787-rtm-2023.03.14-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz || exit
sleep 2
tar xvf softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-x64-64bit.tar.gz -C -|| exit
sleep 2
cd vpnserver || exit
sleep 2
apt install make -y || exit
sleep 5
make || exit
sleep 2
cd .. || exit
sleep 2
sudo mv vpnserver /opt/softether || exit
sleep 2
sudo /opt/softether/vpnserver start || exit
sleep 5
sudo /opt/softether/vpnserver stop || exit
sleep 5
printf "%sCreate the service file%s" "$RED" "$NC"
# Create the service file with the desired content
sudo tee /etc/systemd/system/softether-vpnserver.service > /dev/null << 'EOF'
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
printf "%sdaemon to recognize the new service%s" "$RED" "$NC"
sudo systemctl daemon-reload || exit
sleep 2
# Enable the service to start on boot
printf "%sEnable the service to start on boot%s" "$RED" "$NC"
sudo systemctl enable softether-vpnserver.service || exit
sleep 3
# Start the service
printf "%sStart the service%s" "$RED" "$NC"
sudo systemctl start softether-vpnserver.service || exit
sleep 5
# enable IPv4 forwadring 
printf "%senable IPv4 forwadring%s" "$RED" "$NC"
echo 1 > /proc/sys/net/ipv4/ip_forward || exit
sleep 2
cat /proc/sys/net/ipv4/ip_forward || exit
#Openig port

printf "%sOpenig port%s" "$RED" "$NC"
sudo ufw allow 22
sudo ufw allow 53
sudo ufw allow 2280
sudo ufw allow 2380
sudo ufw allow 443 || exit
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
sleep 5
# Ask the user for confirmation before rebooting
read -p "This script will reboot your system. Are you sure? [y/N] " -n 1 -r
echo # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  # Reboot the system
  reboot
else
  # Exit the script
  echo "Reboot cancelled."
  exit 0
fi
esac
