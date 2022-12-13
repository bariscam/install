#!/bin/bash

# Change the keymap
loadkeys us

# Setup the time
timedatectl set-ntp true

# Setup the partitions

DISKS=$(sfdisk -l | grep Disk)

i=0

while read -r line; do
    i=$(( i+1 ))
    echo "$i --> $line"
done < <(printf '%s\n' "$DISKS")

echo Please choose a disk to install on:

read -r DISK_NR

i=0

while read line; do
  i=$(( i + 1 ))
  case $i in $DISK_NR) echo "$line"; break;; esac
done < <(printf '%s\n' "$DISKS")

DISK=$(echo "$line" | cut -f2 -d' ' | tr -d ':')

while true; do

read -p "$DISK is choosen. Is that correct? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done

# TODO Verify the boot mode
# -> check the efivars
# default is gpt

echo "label: gpt" | sfdisk $DISK

# Creating the Partitions
# EFI Partition
# Swap Partition
# ToDo get the ram size and calculate the swap area
# Linux Partition
# Write the config

echo " , 550M, U, *
       , 2G, S
       , , L" | sfdisk $DISK
#echo "yes " | sfdisk $DISK


while true; do

sfdisk -l
read -p "Is the partitioning correct? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done

# Make the filesystem
echo "Making the filesystem"
mkfs.fat -F32 /dev/sda1
mkswap -F /dev/sda2
swapon /dev/sda2
mkfs.ext4 -F /dev/sda3

# Install the base system
mount /dev/sda3 /mnt

while true; do

mount /dev/sda3 /mnt
read -p "Is the correct partition mounted? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done

echo "Installing the base system"
pacstrap /mnt base linux linux-firmware

echo "Generating the filetable"
# Generate the filetable
genfstab -U /mnt >> /mnt/etc/fstab

# Became root user
arch-chroot /mnt
