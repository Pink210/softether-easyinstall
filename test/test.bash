#!/usr/bin/env bash
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear
# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nSoftEther VPN(v4.41-9798-rtm-2023.06.30) will be downloaded and compiled on your server.do you want continue ? [[y/N]] ' response
case "$response" in
[yY][eE][sS]|[yY])

#remove needrestart for less interruption 
sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# REMOVE PREVIOUS INSTALL
# Check for SE install folder
if [ -d "/opt/vpnserver" ]; then
  sudo systemctl stop softether-vpnserver.service
  sudo systemctl stop softether-vpnserver
  sleep 3
  sudo cp /opt/vpnserver/vpn_server.config /opt/vpn_server.config.bak
  sudo cp /opt/softether/vpn_server.config /opt/vpn_server.config.bak
  sleep 2
  sudo rm -rf /opt/vpnserver
  sudo rm -rf /opt/softether
fi

# Check for init script
if
  [ -f "/etc/init.d/vpnserver" ]; then rm /etc/init.d/vpnserver;
fi

# Remove vpnserver from systemd
systemctl disable vpnserver > /dev/null 2>&1

# Start from here
# Perform apt update & install necessary software
sudo apt-get update -y && sudo apt-get -o Dpkg::Options::="--force-confold" -y upgrade -y && sudo apt-get autoremove -y 
sleep 2

# Install some usfull tools
sudo apt-get install -y certbot && sudo apt-get install -y ncat && sudo apt-get install -y net-tools
sleep 2
# Install dependency
sudo apt install -y gcc binutils gzip libreadline-dev libssl-dev libncurses5-dev libncursesw5-dev libpthread-stubs0-dev || exit
sleep 2

#SET certificate
read -rp "Do you want to set certificate on your server? " -n 1 REPLY
printf '\n' # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf 'enter your domain name?\n'
  read -r ser # This reads input from the user and stores it in the variable name
  printf 'enter your email address?\n'
  read -r email # This reads input from the user and stores it in the variable name
  if sudo certbot certonly --standalone --preferred-challenges http --agree-tos --email "$email" -d "$ser"
  then
    printf 'Certificate successfully installed and VPN server restarted.\n'
  else
    printf 'Certificate installation failed.\n'
  fi  
else
  printf 'Certificate installation skipped.\n'
fi


# Download SoftEther | Version 4.42 | Build 9798
wget https://www.softether-download.com/files/softether/v4.42-9798-rtm-2023.06.30-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz || exit
sleep 2
tar xvf softether-vpnserver-v4.42-9798-rtm-2023.06.30-linux-x64-64bit.tar.gz || exit
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
sudo systemctl daemon-reload || exit
sleep 2
# Enable the service to start on boot
sudo systemctl enable softether-vpnserver.service || exit
sleep 3
# Start the service
sudo systemctl start softether-vpnserver.service || exit
sleep 5
# enable IPv4 forwadring 
echo 1 > /proc/sys/net/ipv4/ip_forward || exit
sleep 2
cat /proc/sys/net/ipv4/ip_forward || exit

# Openig port
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

# Restore backup
sudo cp /opt/vpn_server.config.bak /opt/softether/vpn_server.config

#add needrestart back again
sudo sed -i "s/#\$nrconf{restart} = 'a';/\$nrconf{restart} = 'i';/" /etc/needrestart/needrestart.conf


# Ask the user for installing BBR
read -p "Do you want entering softether setting? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  # installing
    echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" | tee -a /etc/sysctl.conf
    # Apply changes
    sysctl -p
    
    echo "Have FUN ;)."
else
  # Exit the script
  echo "Have FUN ;)."
  exit 0
fi
esac
