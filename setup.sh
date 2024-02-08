#!/usr/bin/env bash

###############################################################################
# █░█ ▄▀█ █▀█ █ ▄▀█ █▄▄ █░░ █▀▀ █▀
# ▀▄▀ █▀█ █▀▄ █ █▀█ █▄█ █▄▄ ██▄ ▄█
###############################################################################

DISK_ID='nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O'
SWAP_SIZE='18GB'
BOOT_SIZE='1GB'
FLAKE_REPO='https://github.com/KaigyoTV/vtuberous'


###############################################################################
# █▀█ ▄▀█ █▀█ ▀█▀ █ ▀█▀ █ █▀█ █▄░█ █▀
# █▀▀ █▀█ █▀▄ ░█░ █ ░█░ █ █▄█ █░▀█ ▄█
###############################################################################

# Partition numbering is: 1. root, 2. swap, 3. boot
parted "/dev/disk/by-id/${DISK_ID}" -- mklabel gpt
parted "/dev/disk/by-id/${DISK_ID}" -- mkpart root ext4 ${BOOT_SIZE} "-${SWAP_SIZE}"
parted "/dev/disk/by-id/${DISK_ID}" -- mkpart swap linux-swap "-${SWAP_SIZE}" 100%
parted "/dev/disk/by-id/${DISK_ID}" -- mkpart ESP fat32 1MB ${BOOT_SIZE}
parted "/dev/disk/by-id/${DISK_ID}" -- set 3 esp on



###############################################################################
# █▀▀ █▀█ █▀█ █▀▄▀█ ▄▀█ ▀█▀ ▀█▀ █ █▄░█ █▀▀
# █▀░ █▄█ █▀▄ █░▀░█ █▀█ ░█░ ░█░ █ █░▀█ █▄█
###############################################################################

sudo mkswap -L swap "/dev/disk/by-id/${DISK_ID}-part2"
mkfs.fat -F 32 -n boot "/dev/disk/by-id/${DISK_ID}-part3"
zpool create rpool "/dev/disk/by-id/${DISK_ID}-part1"



###############################################################################
# ▀█ █▀▀ █▀   █▀▄ ▄▀█ ▀█▀ ▄▀█ █▀ █▀▀ ▀█▀ █▀
# █▄ █▀░ ▄█   █▄▀ █▀█ ░█░ █▀█ ▄█ ██▄ ░█░ ▄█
###############################################################################

zfs create -p -o mountpoint=legacy rpool/local/root
zfs snapshot rpool/local/root@blank
zfs create -p -o mountpoint=legacy rpool/local/nix
zfs create -p -o mountpoint=legacy rpool/safe/home
zfs create -p -o mountpoint=legacy rpool/safe/persist



###############################################################################
# █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀
# █░▀░█ █▄█ █▄█ █░▀█ ░█░
###############################################################################

mount -t zfs rpool/local/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
mkdir /mnt/nix
mount -t zfs rpool/local/nix /mnt/nix
mkdir /mnt/home
mount -t zfs rpool/safe/home /mnt/home
mkdir /mnt/persist
mount -t zfs rpool/safe/persist /mnt/persist



###############################################################################
# █▀ █▀▀ █▀▀ █▀█ █▀▀ ▀█▀ █▀
# ▄█ ██▄ █▄▄ █▀▄ ██▄ ░█░ ▄█
###############################################################################

mkdir /mnt/persist/etc
cp /etc/machine-id /mnt/persist/etc/machine-id
mkdir /mnt/persist/etc/ssh
cp /etc/ssh/ssh_host_ed25519_key /mnt/persist/etc/ssh/ssh_host_ed25519_key
cp /etc/ssh/ssh_host_rsa_key /mnt/persist/etc/ssh/ssh_host_rsa_key



###############################################################################
# █▀▀ █░░ ▄▀█ █▄▀ █▀▀
# █▀░ █▄▄ █▀█ █░█ ██▄
###############################################################################

nixos-generate-config --root /mnt
git clone ${FLAKE_REPO} /mnt/persist/etc/nixos
cp -f /mnt/etc/nixos/hardware-configuration.nix /mnt/persist/etc/nixos/hardware-configuration.nix

