#!/bin/bash

# Set the timezone
ln -sf /usr/share/zoneinfo/Europe/Amsterdam

# Set hardware clock
hwclock --systohc

# Edit locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Create host name
touch /etc/hostname
echo "bariscam" >> /etc/hostname

# Create host config
echo "127.0.0.1 localhost
      ::1       localhost
      127.0.1.1 bariscam.localdomain bariscam" >> /etc/hosts
   
# Set root password
echo "Please create a password for the root user: "
passwd

# Add user
useradd -m bariscam
echo "Please create a password for the local user: "
passwd bariscam

#Add user to group
usermod -aG wheel,audio,video,optical,storage bariscam

# Install sudo
pacman -Sy sudo
# TODO: uncommment wheel group >>EDITOR=vim visudo

# Install grub
pacman -Sy grub

# Install EFI packages
pacman -Sy efibootmgr dosfstools os-prober mtools

# Make the boot directory
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

# Make the grub config
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot
exit

# Reboot system
reboot

# Extra packages
#pacman -Sy networkmanager vim git
