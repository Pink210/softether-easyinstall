# SoftEther VPN Server Installer

This is a bash script that automates the installation and configuration of the SoftEther VPN Server on Ubuntu 20.04 or later. SoftEther VPN Server is a powerful and easy-to-use multi-protocol VPN software that runs on Linux, Windows, Mac, FreeBSD, and Solaris.

## Table of Contents

- [Features](#features)
- [Install & Update](#install)
- [Uninstall](#uninstall)
- [Update](#update)
- [Security](#security)
- [Resources](#resources)
- [Disclaimer](#disclaimer)
- [Certificate](#certificate)

## Features

- Updates your Linux system and installs some useful tools such as Certbot, Ncat, and Net-tools.
- Downloads and compiles the latest version of SoftEther VPN Server (v4.43-9799-rtm-2023.08.31) from the official website.
- Creates a systemd service for SoftEther VPN Server and enables it to start on boot.
- Enables IPv4 forwarding for VPN traffic.
- Opens the necessary ports for VPN protocols using ufw firewall.
- Update  SoftEther VPN Server without losing config(Be careful)
- Optionally, set up a certificate from Let's Encrypt using Certbot for secure VPN connections.
- Optionally, installs BBR.
- Optionally, disable DDns(Dynamic DNS)

## Install

<details>
  <summary>Click here for Install & Update details</summary>

To install the script, simply copy and paste it on your Linux server in terminal
  
#### FOR AMD / INTEL CPU
```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install-ubuntu-inteloramd.bash  && chmod +x se-install && ./se-install
```
#### FOR ARMS64 CPU
```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install-ubuntu-arms.bash  && chmod +x se-install && ./se-install
```
#### FOR Developer Edition (DE)
```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install_DE.bash  && chmod +x se-install && ./se-install
```



There is no need to configure SoftEtherVPN with a password. Later, you can use SoftEther VPN Server Manager (Windows).
To use this script, you need to have root privileges or be able to run commands with sudo.
The script will ask you for confirmation before proceeding with the installation. It will also ask you if you want to set up a certificate from Let's Encrypt and if you want to enter the SoftEther VPN Server settings.
The installation process may take several minutes depending on your system and network speed. After the installation is complete, you can use the vpncmd tool to configure your VPN server. For more information on how to use vpncmd, please refer to the [official documentation](https://www.softether.org/4-docs/1-manual/6._Command_Line_Management_Utility_Manual).

</details>


## Uninstall

<details>
  <summary>Uninstall</summary>
You can uninstall SoftetherVPN on your server automatically with the script or just do it manually by copying and past the code
  
<details>
  <summary>automatically</summary>
Use this code :

```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/Uninstall.bash  && chmod +x se-install && ./se-install
```
</details>

<details>
<summary>manually</summary>

follow these steps:

- Stop and disable the systemd service:

```bash
sudo systemctl stop softether-vpnserver.service
sudo systemctl disable softether-vpnserver.service
```

- Remove the vpnserver directory from /opt:

```bash
sudo rm -rf /opt/vpnserver
```

- Remove the softether-vpnserver.service file from /etc/systemd/system:

```bash
sudo rm /etc/systemd/system/softether-vpnserver.service
```

- Reload the systemd daemon:

```bash
sudo systemctl daemon-reload
```

- Close the ports that were opened by the script using ufw:

```bash
sudo ufw deny 22
sudo ufw deny 53
sudo ufw deny 2280
sudo ufw deny 2380
sudo ufw deny 443 
sudo ufw deny 80
sudo ufw deny 992
sudo ufw deny 1194
sudo ufw deny 2080
sudo ufw deny 5555
sudo ufw deny 4500
sudo ufw deny 1701
sudo ufw deny 500
sudo ufw deny 8280
sudo ufw deny 500,4500,8280,53/udp
```
</details>
</details>

## Update

If you already have Softether installed on your server but want to update it to the latest version you can use the install code.
the script now makes a backup, update, and restore your backup.
but is more safe to do it Manual or just make a backup with Softether Windows software.

<details>
  <summary>Click here for an update SoftEther VPN Server Manual</summary>
To update the SoftEther VPN Server to the latest version, you can follow these steps:

- Stop the systemd service:

```bash
sudo systemctl stop softether-vpnserver.service
```

- Backup your VPN server configuration file:

```bash
sudo cp /opt/vpnserver/vpn_server.config /opt/vpnserver/vpn_server.config.bak
```

- Download and compile the new version of SoftEther VPN Server from the official website:

FOR AMD / INTEL CPU
```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install-ubuntu-inteloramd.bash  && chmod +x se-install && ./se-install
```
FOR ARMS64 CPU
```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install-ubuntu-arms.bash  && chmod +x se-install && ./se-install
```

- Restore your VPN server configuration file:

```bash
sudo cp /opt/vpnserver/vpn_server.config.bak /opt/vpnserver/vpn_server.config
```

- Restart the systemd service:

```bash
sudo systemctl restart softether-vpnserver
```
</details>


## Security

now you can disable DDns from auto-installer
disable DDns(Dynamic DNS)
<details>
  <summary>Click here disable DDns</summary>
You may disable DDns (Dynamic DNS) for further protection, but you must have a domain and a certificate to do so.
  
```bash
sed -i 's/bool Disabled false/bool Disabled true/g' /opt/softether/vpn_server.config
```
```bash
sed -i 's/bool DisableNatTraversal false/bool DisableNatTraversal true/g' /opt/softether/vpn_server.config
```
```bash
sudo systemctl restart softether-vpnserver
```

</details>

## Certificate

If you have a domain, you must configure the certificate as follows in Softether Settings:
<details>
  <summary>Click here for details</summary>
NOTE: Only enter one line of code at a time. Do not simply copy and paste everything.| On line 4,5, replace "YourDomainName" with your domain name. Skip line 1 and start at line 2 if you're currently in Softether Settings.
  
```bash
vpmcmd (if vpmcmd not work reboot your linux server and try it again)
 you server password
 ServerCertSet
 /etc/letsencrypt/live/YourDomainName/fullchain.pem
 /etc/letsencrypt/live/YourDomainName/privkey.pem
 exit
 sudo systemctl restart softether-vpnserver
```
</details>

## Other
It is not advised that you remove the log, although you may do so:

 ```bash
 cd .. && cd opt/softether && rm -r packet_log security_log server_log
 ```

For SoftEtherVPN setting :
just type vpncmd in the Linux terminal 

 ```bash
vpncmd
 ```

To reset client traffic:

 ```bash
wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/reset-traffic-bbr.bash  && chmod +x se-install && ./se-install
 ```


```[tasklist]
### My tasks
- [X] Get Server certificate
- [X] Disable update popup
- [ ] Set ServerCertSet 
- [X] Adding BBR
- [X] Make backup/install/restore for update into the script
- [X] Uninstall script
- [X] Adding disable DDns into the script
- [X] Adding Close the extra ports into the script
- [X] Make a script for restarting client traffic
- [X] Make a shortcut for the SoftEtherVPN setting
```
## Resources

Here are some links to other resources or tutorials on how to use SoftEther VPN Server or how to set up different VPN protocols:

- [SoftEther VPN Project](https://www.softether.org/)
- [SoftEther VPN User Forum](https://forum.vpnusers.com/)
- [How to Set Up SoftEther VPN on Windows](https://www.vpnranks.com/setup-vpn/windows/softether/)
- [How to Set Up SoftEther VPN on Android](https://www.vpnranks.com/setup-vpn/android/softether/)

## Disclaimer

This script is provided as-is without any warranty or support. Use it at your own risk. The author is not responsible for any damage or loss caused by using this script.

THANK YOU Daiyuu Nobori for making this beautiful software.
