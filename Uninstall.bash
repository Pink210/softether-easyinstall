#!/usr/bin/env bash
(( EUID != 0 )) && exec sudo -- "$0" "$@"
clear
# User confirmation
read -rep $'!!! IMPORTANT !!!\n\nAre you certain you want to get rid of SoftetherVPN from your Linux? [[y/N]] ' response
case "$response" in
[yY][eE][sS]|[yY])

# Check for the original version
if [ -d "/opt" ];
then
  if [ -d "/opt/vpnserver" ]; 
  then
    echo "Uninstalling ..."
    sudo systemctl stop softether-vpnserver.service
    sleep 2
    sudo mkdir /opt/backup
    sleep 2
    sudo cp -f /opt/vpnserver/vpn_server.config /opt/backup/vpn_server.config.bak
    sleep 2
    sudo cp -rf /opt/vpnserver/backup.vpn_server.config /opt/backup/backup.vpn_server.config 
    sleep 2
    sudo rm -rf /opt/vpnserver
    sudo systemctl disable vpnserver
    sudo rm /etc/systemd/system/softether-vpnserver.service
    sleep 2
    sudo systemctl daemon-reload
    clear
    echo "Uninstall Complete."
  else 
    echo "Uninstalling ..."
    sudo systemctl stop softether-vpnserver
    sleep 2
    sudo mkdir /opt/backup
    sleep 2
    sudo cp -f /opt/softether/vpn_server.config /opt/backup/vpn_server.config.bak
    sleep 2
    sudo cp -rf /opt/softether/backup.vpn_server.config /opt/backup/backup.vpn_server.config 
    sleep 2
    sudo rm -rf /opt/softether
    sudo systemctl disable softether-vpnserver
    sudo rm /etc/systemd/system/softether-vpnserver.service
    sudo systemctl daemon-reload
    clear
    echo "Uninstall Complete."
else
echo "Softether is not installed on this server."
fi
