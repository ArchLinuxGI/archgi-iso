#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/bash root
cp -aT /etc/skel/ /root/
chmod 700 /root

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

# add archnet
useradd -m archnet -u 500 -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash
passwd -d archnet
chown -R archnet:users /home/archnet
# enable autologin
groupadd -r autologin
gpasswd -a archnet autologin
groupadd -r nopasswdlogin
gpasswd -a archnet nopasswdlogin
echo "The account archnet with no password has been created"

systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target
systemctl set-default graphical.target
systemctl enable NetworkManager.service
#systemctl enable virtual-machine-check.service
systemctl enable lightdm.service
systemctl enable vmtoolsd.service



reflector -f 30 -l 30 --number 10 --save /etc/pacman.d/mirrorlist
pacman -Sc --noconfirm
pacman -Syyu --noconfirm
