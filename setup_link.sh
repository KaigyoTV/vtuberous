#!/usr/bin/env bash
set -e

rm /mnt/etc/nixos/configuration.nix
rm /mnt/etc/nixos/hardware-configuration.nix
ln -s ../../persist/etc/nixos/flake.nix /mnt/etc/nixos/flake.nix
ln -s ../../persist/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix
ln -s ../../persist/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix
