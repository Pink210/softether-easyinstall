#!/usr/bin/env bash
(( EUID != 0 )) && exec sudo -- "$0" "$@"
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'
clear
# Reset client traffic
echo -e "${red}SoftEtherVPN${plain}.\n"
read -rp "Do you want to Reset client traffic 'y' or 'n'" -n 1 REPLY
printf '\n' # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo systemctl stop softether-vpnserver
  sed -i 's/\(uint64 BroadcastBytes\) [0-9]*/\1 0/g' /opt/softether/vpn_server.config
  sleep 2
  sed -i 's/\(uint64 BroadcastCount\) [0-9]*/\1 0/g' /opt/softether/vpn_server.config
  sleep 2
  sed -i 's/\(uint64 UnicastBytes\) [0-9]*/\1 0/g' /opt/softether/vpn_server.config
  sleep 2
  sed -i 's/\(uint64 UnicastCount\) [0-9]*/\1 0/g' /opt/softether/vpn_server.config
  sleep 2
  sudo systemctl restart softether-vpnserver
  echo -e "${green}Reset client traffic Successfully ${plain}.\n"
else
  echo -e "${red}Reset client traffic skipped ${plain}.\n"
fi
# Exit the script
  clear
  echo -e "${red} USE 'vpncmd' FOR Softether Setting ${plain}"
  echo "Have FUN ;)."
  exit 0
fi
