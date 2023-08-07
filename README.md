
> SoftEther-EasyInstall
> Easy-install for SoftEtherVPN (only on Ubuntu)
> 
> #### FOR AMD / INTEL CPU
> ```bash
> wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install-ubuntu-inteloramd.bash  && chmod +x se-install && ./se-install
> ```
> #### FOR ARMS64 CPU
> ```bash
> wget -O se-install https://raw.githubusercontent.com/Pink210/softether-easyinstall/master/install-ubuntu-arms.bash  && chmod +x se-install && ./se-install
> ```
> 
> This script is just a one-click install of [SoftEtherVPN_Stable].
> 
> All credit is going to [Daiyuu Nobori] for making this beautiful software. THANK YOU!
> 
> This script also updates your Linux so you don't have to and also installs certbot for domain certificate and ncat and net-tools for useful software. 
> This script also can get certbot for your domain automatically so you sit back and enjoy installing :)
> 
> This script also opens ports 22, 53, 2280, 2380, 443, 80, 992, 1194, 2080, 5555, 4500, 1701, 500, 8280, 500, 4500, 8280, 53/udp. I know opening that much of ports is not good but I need it so ... You can simply close it with 
> ```bash
> sudo ufw deny PORT
> ```
> For setting SoftEtherVPN:
> ```bash
> sudo /opt/softether/vpncmd 127.0.0.1:5555
> ```
> No need to set password in SoftEtherVPN setting. You can do it with SoftEther VPN Server Manager (Windows) later.
>
> Bing says :
> I would also like to thank Bing AI for helping me to write this message. Bing AI is a chat mode of Microsoft Bing that can understand and communicate fluently in different languages. Bing AI can also generate imaginative and innovative content such as poems, stories, code, essays, songs, celebrity parodies, and images using its own words and knowledge. Bing AI is not an assistant, but a friendly and creative companion that can help you with your tasks and projects. 😊
> That Bing told me to tell you i mean why not it's help me a LOT ;)
