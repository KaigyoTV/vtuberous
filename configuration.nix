# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, lib, inputs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "vtuberous"; # Define your hostname.
  networking.hostId = "e16daa5b";
 
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages = with pkgs; [ powerline-fonts ];
    font = "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v32n.psf.gz";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
  };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # allow wayland windows to peform admin tasks
  security.polkit.enable = true; 

  # Disable sudo lecture
  security.sudo.extraConfig = ''
    Defaults lecture="never"
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.mutableUsers = false;
  users.users.kaigyo = {
    uid = 1000;
    initialHashedPassword = builtins.readFile "/persist/password";
    isNormalUser = true;
    extraGroups = [ 
      "wheel" # Enable ‘sudo’
      "audio" # Audio management
      "systemd-journal" # Access to journal logs
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5yF+j+AUNK6FClusJt3LUwrZjquHc0bwzhzJAHRaRd kai@g.yo.eco"
    ];
    packages = with pkgs; [
      dolphin
      ffmpeg-full
      firefox
      git
      kitty
      micro
      neofetch
      swww
      vscodium
      xdg-ninja
    ];
  };

  # Auto-login user
  services.getty.autologinUser = "kaigyo";

  # System packages
  environment.systemPackages = with pkgs; [
    cifs-utils
    killall
    screen
    tree
  ];

  # Allow easy patching of library path
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      ffmpeg-full
      inputs.hycov.packages.${pkgs.system}.hycov
      inputs.hyprfocus.packages.${pkgs.system}.hyprfocus
      libGL
      pipewire
      glib
      dbus-glib
      dbus
      zlib
    ];
  };

  # ZSH + Oh my ZSH
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" ];
    };
  };

  # Hyprland window compositor
  programs.hyprland = {
    enable = true;
    #enableNvidiaPatches = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Erase your darlings
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  # Persist necessary things
  boot.initrd.postMountCommands = lib.mkBefore ''
    ln -sf /persist/etc/machine-id /etc/machine-id
  ''; # machine id is needed very early
  environment.etc = {
    "ssh/ssh_host_ed25519_key".source = "/persist/etc/ssh/ssh_host_ed25519_key";
    "ssh/ssh_host_rsa_key".source = "/persist/etc/ssh/ssh_host_rsa_key";
  };

  # Environment variables
  environment.sessionVariables = rec {
    # XDG home paths
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    # Configure apps to use XDG home
    ERRFILE = "$XDG_CACHE_HOME/X11/xsession-errors";
    HISTFILE = "$XDG_STATE_HOME/zsh/history";
    LESSHISTFILE = "$XDG_CACHE_HOME/less/history";
    XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    # Other stuff
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Use flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

 
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}