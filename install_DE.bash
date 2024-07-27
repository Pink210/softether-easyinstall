#!/usr/bin/env bash
(( EUID != 0 )) && exec sudo -- "$0" "$@"
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
clear

# progress bar
show_progress() {
  local duration=${1}
  local interval=1
  local elapsed=0
  echo -ne '['
  while ((elapsed < duration)); do
    sleep "$interval"
    printf '▓'
    elapsed=$((elapsed + interval))
  done
  echo -ne "]\n"
}

# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nSoftEther VPN(Developer Edition) will be downloaded and compiled on your server. Do you want to continue? [[y/N]] ' response
case "$response" in
[yY][eE][sS]|[yY])

# Remove needrestart for less interruption 
sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf


# Perform apt update & install necessary software
clear
echo -e "${green}Updating Linux server.${plain}"
(sudo apt-get update -y && sudo apt-get -o Dpkg::Options::="--force-confold" -y full-upgrade -y && sudo apt-get autoremove -y) &
show_progress 20
sleep 2

# Install some useful tools
clear
echo -e "${green}Install some useful tools.${plain}"
(sudo apt-get install -y certbot && sudo apt-get install -y ncat && sudo apt-get install -y net-tools) &
show_progress 15
sleep 2

# Install dependency
clear
echo -e "${green}Install dependency.${plain}"
(sudo apt -y install cmake gcc g++ make pkgconf libncurses5-dev libssl-dev libsodium-dev libreadline-dev zlib1g-dev || exit) &
show_progress 15
sleep 2
clear

# Download SoftEther
echo -e "${green}Download & Install SoftEther | Developer Edition.${plain}.\n"
git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git || exit
sleep 2
cd SoftEtherVPN || exit
sleep 2
git submodule init && git submodule update || exit
sleep 2
./configure || exit
sleep 5
make -C build || exit
sleep 2
sudo make -C build install || exit
sleep 2


# Start service
vpnserver start
sleep 2

# Enable IPv4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward || exit
sleep 2
cat /proc/sys/net/ipv4/ip_forward || exit

# Opening port
echo -e "${green}Opening port And Enable FireWall.${plain}.\n"
sudo ufw allow ssh
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw enable
sudo ufw allow 22
sudo ufw allow 53
sudo ufw allow 443 || exit
sudo ufw allow 80
sudo ufw allow 992
sudo ufw allow 1194 || exit
sudo ufw allow 2080
sudo ufw allow 5555
sudo ufw allow 4500
sudo ufw allow 1701
sudo ufw allow 500
sudo ufw allow 500,4500,2080,53/udp
sudo ufw reload
sleep 5
clear

# Set Certificate
read -rp "Do you want to set a certificate on your server? 'y' or 'n'" -n 1 REPLY
printf '\n' # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  printf 'enter your domain name?\n'
  read -r ser # This reads input from the user and stores it in the variable name
  printf 'enter your email address?\n'
  read -r email # This reads input from the user and stores it in the variable name
  if sudo certbot certonly --standalone --preferred-challenges http --agree-tos --email "$email" -d "$ser"
  then
    echo -e "${green}Certificate successfully installed and VPN server restarted.${plain}.\n"
  else
    echo -e "${red}Certificate installation failed.${plain}.\n"
  fi  
else
  echo -e "${yellow}Certificate installation skipped.${plain}.\n"
fi

# Add need-restart back again
sudo sed -i "s/#\$nrconf{restart} = 'a';/\$nrconf{restart} = 'i';/" /etc/needrestart/needrestart.conf

esac # End of case statement
