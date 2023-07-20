#!/usr/bin/env bash
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear
# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nIf SoftEther was already installed, this script will remove it. If you are updating, please backup your config file first. SoftEther VPN(v4.41-9787-rtm-2023.03.14) will be downloaded and compiled on your server. Are you sure you want to move forward? [[y/N]] ' response
case "$response" in
[yY][eE][sS]|[yY])

sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

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

# Start from here
# Perform apt update & install necessary software
sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y 
sleep 2

# Install some usfull tools
sudo apt-get install -y certbot && sudo apt-get install -y ncat && sudo apt-get install -y net-tools
sleep 2
# Install dependency
sudo apt install -y gcc binutils gzip libreadline-dev libssl-dev libncurses5-dev libncursesw5-dev libpthread-stubs0-dev || exit
sleep 2

# Download SoftEther | Version 4.41 | Build 9787
wget https://www.softether-download.com/files/softether/v4.41-9787-rtm-2023.03.14-tree/Linux/SoftEther_VPN_Server/64bit_-_ARM_64bit/softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-arm64-64bit.tar.gz || exit
sleep 2
tar xvf softether-vpnserver-v4.41-9787-rtm-2023.03.14-linux-arm64-64bit.tar.gz || exit
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
sleep 3

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
    sleep 3
    sudo /opt/softether/vpncmd 127.0.0.1:5555
    sleep 3
    ServerCertSet
    sleep 3
    /etc/letsencrypt/live/"$ser"/fullchain.pem
    sleep 3
    /etc/letsencrypt/live/"$ser"/privkey.pemexit
    sleep 3
    exit
    sleep 3
    sudo systemctl restart softether-vpnserver
    sleep 3
    printf 'Certificate successfully installed and VPN server restarted.\n'
  else
    printf 'Certificate installation failed.\n'
  fi  
else
  printf 'Certificate installation skipped.\n'
fi

#installin BBR
read -rp "Do you want to install BBR y/N " -n 1 REPLY
printf '\n' # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  if wget -N --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && bash bbr.sh
  then
    printf 'BBR successfully installed.\n'
  else
    printf 'BBR installation failed.\n'
  fi
else
  printf 'BBR installation skipped.\n'
fi

#namizun
read -rp "Do you want to install BBR y/N " -n 1 REPLY
printf '\n' # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  if sudo curl https://raw.githubusercontent.com/malkemit/namizun/master/else/setup.sh | sudo bash
  then
    printf 'Namizun successfully installed.\n'
  else
    printf 'Namizun installation failed.\n'
  fi
else
  printf 'Namizun installation skipped.\n'
fi


sleep 3
sed -i "s/#\$nrconf{restart} = 'a';/\$nrconf{restart} = 'i';/" /etc/needrestart/needrestart.conf
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
