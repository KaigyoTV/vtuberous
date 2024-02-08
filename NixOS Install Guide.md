If you're like me an you bought a cheap refurbished optiplex, there's a few things you'll want to do before installing:
- Disable secure boot (so you can enable legacy ROMs)
- Enable legacy ROMs (so you can boot from USB)
- Change the SATA mode to AHCI (so you'll be able to see the disk in linux)

Figure out which disk you're installing to:
- Run `ls /dev/disk/by-id`
- My disk's id looks like `nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O`

Decide how much swap space you'll want:
- My machine has 16GB of RAM, so I'm going to go with RAM size + 2GB = 18GB
- You'll see this 18GB number appear in the partition creation below, so make sure to substitute your value!

Decide how big to make the boot partition:
- NixOS's install guide specifies 512MB, but I'm going to do 1GB in case I want to throw unnecessary bs into /boot. I'm not going to miss another 512MB.
- You'll see this 1GB number appear in the partition creation below, so make sure to substitute your value!

<!-- Delete the current partition table just so it doesn't interfere with anything:
- Run `sudo sfdisk --delete /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O`
- Run `ls /dev/disk/by-id` to confirm that the partitions are gone -->

Follow the NixOS installation guide for creating your partition table:
- Run `sudo parted /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O -- mklabel gpt`
- Run `sudo parted /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O -- mkpart root ext4 1GB -18GB`
- Run `sudo parted /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O -- mkpart swap linux-swap -18GB 100%`
- Run `sudo parted /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O -- mkpart ESP fat32 1MB 1GB`
- Run `sudo parted /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O -- set 3 esp on`

Follow the NixOs installation guide for formatting the partitions, but skip the ext4 formatting step on the root partition since we're going to use zfs:
- Run `sudo mkswap -L swap /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O-part2`
- Run `sudo mkfs.fat -F 32 -n boot /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O-part3`

Turn the swap on (optional)
- Run `sudo swapon /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O-part2`

Create a zfs pool named rpool
- Run `sudo zpool create rpool /dev/disk/by-id/nvme-BC501_NVMe_SK_hynix_256GB_NN9CN8716101Y172O-part1`
- You can name the pool something else, but this guide will use rpool as the name in the commands

Following the Delete Your Darlings guide:
- Run `sudo zfs create -p -o mountpoint=legacy rpool/local/root`
- Run `sudo zfs snapshot rpool/local/root@blank`
- Run `sudo mount -t zfs rpool/local/root /mnt`
- Run `sudo mkdir /mnt/boot`
- Run `sudo mount /dev/disk/by-label/boot /mnt/boot`
- Run `sudo zfs create -p -o mountpoint=legacy rpool/local/nix`
- Run `sudo mkdir /mnt/nix`
- Run `sudo mount -t zfs rpool/local/nix /mnt/nix`
- Run `sudo zfs create -p -o mountpoint=legacy rpool/safe/home`
- Run `sudo mkdir /mnt/home`
- Run `sudo mount -t zfs rpool/safe/home /mnt/home`
- Run `sudo zfs create -p -o mountpoint=legacy rpool/safe/persist`
- Run `sudo mkdir /mnt/persist`
- Run `sudo mount -t zfs rpool/safe/persist /mnt/persist`

Generate the default config:
- Run `nixos-generate-config --root /mnt`

Collect some things we don't want deleted:
- Run `mkdir /mnt/persist/etc`
- Run `cp /etc/machine-id /mnt/persist/etc/machine-id`
- Run `mkdir /mnt/persist/etc/ssh`
- Run `cp /etc/ssh/ssh_host_ed25519_key /mnt/persist/etc/ssh/ssh_host_ed25519_key`
- Run `cp /etc/ssh/ssh_host_rsa_key /mnt/persist/etc/ssh/ssh_host_rsa_key`
- Run `cp -r /mnt/etc/nixos /mnt/persist/etc/nixos`


