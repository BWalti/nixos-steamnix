# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree         = true;

  # kernel hack for Thunderbolt
  boot.kernelParams = [
    "thunderbolt.host_reset=false"
    "iommu=pt"
    "amdgpu.runpm=0"
    "amdgpu.ppfeaturemask=0xffffffff"
  ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.amdgpu.amdvlk = {
    enable = true;
    support32Bit.enable = true;
  };

  # use AMD GPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  hardware.amdgpu.initrd.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout                  = 0;
  boot.loader.limine.maxGenerations    = 5;

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernel.sysctl = {
    "kernel.split_lock_mitigate" = 0;
    "kernel.nmi_watchdog"        = 0;
    "kernel.sched_bore"          = "1";
  };

  boot.plymouth.enable     = true;

  networking.hostName = "gtr7pro01"; # Define your hostname.

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_CH.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bibolorean = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # git
    ];
  };

  environment.systemPackages = with pkgs; [
    # wget
    git
    lact

# Plasma / KDE:
    kdePackages.discover # Optional: Install if you use Flatpak or fwupd firmware update sevice
    kdePackages.kcalc # Calculator
    kdePackages.kcharselect # Tool to select and copy special characters from all installed fonts
    kdePackages.kcolorchooser # A small utility to select a color
    kdePackages.kolourpaint # Easy-to-use paint program
    kdePackages.ksystemlog # KDE SystemLog Application
    kdePackages.sddm-kcm # Configuration module for SDDM
    kdiff3 # Compares and merges 2 or 3 files or directories
    kdePackages.isoimagewriter # Optional: Program to write hybrid ISO files onto USB disks
    kdePackages.partitionmanager # Optional Manage the disk devices, partitions and file systems on your computer
    hardinfo2 # System information and benchmarks for Linux systems
    haruna # Open source video player built with Qt/QML and libmpv
    wayland-utils # Wayland utilities
    wl-clipboard # Command-line copy/paste utilities for Wayland

    # Steam related
    mangohud

    # Curated list of desktop utilities
    kdePackages.konsole                # Terminal emulator
    kdePackages.dolphin                # File manager
    kdePackages.plasma-nm  # WiFi management applet (requires NetworkManager)
    kdePackages.spectacle              # Screenshot tool
    kdePackages.ark                    # Archive manager
    kdePackages.systemsettings         # System settings GUI
    kdePackages.plasma-browser-integration
    kdePackages.plasma-nm
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  system.stateVersion = "25.05"; # Did you read the comment?

  ################
  # FileSystems  #
  ################
  fileSystems."/" = {
    options = [ "compress=zstd" ];
  };

  ############
  # Network  #
  ############
  # networking = {
  #   firewall.enable       = false;
  # };

  #################
  # Thunderbolt   #
  #################
  services.hardware.bolt.enable = true;

  #################
  # Bluetooth     #
  #################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      MultiProfile     = "multiple";
      FastConnectable  = true;
    };
  };

  #################
  # Sound & RTKit #
  #################
  security.rtkit.enable = true;
  services.pipewire = {
    enable         = true;
    alsa.enable    = true;
    alsa.support32Bit = true;
    pulse.enable   = true;
  };

  ########################
  # Graphical & Greetd   #
  ########################
  services.xserver.enable            = false;
  # services.getty.autologinUser       = "steamos";
  #services.greetd = {
  #  enable   = true;
  #  settings.default_session = {
  #    user    = "steamos";
  #    command = "steam-gamescope > /dev/null 2>&1";
  #  };
  #};
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "steamos";

  ########################
  # Programs & Gaming    #
  ########################
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "gtk";
  
  programs.steam.gamescopeSession.args = ["-w 1920" "-h 1080" "-r 120" "--xwayland-count 2" "-e" "--hdr-enabled" "--mangoapp" ];
  
  programs = {
    appimage = { enable = true; binfmt = true; };
    fish     = { enable = true; };
    mosh     = { enable = true; };
    tmux     = { enable = true; };

    gamescope.enable = true;
    gamescope.capSysNice  = true;

    steam = {
      enable                = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      gamescopeSession.enable = true;
      extraCompatPackages   = with pkgs; [ proton-ge-bin ];
      extraPackages         = with pkgs; [
        mangohud
        gamescope-wsi
      ];
    };
  };

  environment.sessionVariables = {
    PROTON_USE_NTSYNC       = "1";
    ENABLE_HDR_WSI          = "1";
    DXVK_HDR                = "1";
    PROTON_ENABLE_AMD_AGS   = "1";
    PROTON_ENABLE_NVAPI     = "1";
    ENABLE_GAMESCOPE_WSI    = "1";
    STEAM_MULTIPLE_XWAYLANDS = "1";
  };

  ###################
  # Virtualization  #
  ###################
  virtualisation.docker.enable      = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.libvirtd.enable = true;

  ###############
  # Users       #
  ###############
  users.users.steamos = {
    isNormalUser = true;
    description  = "SteamOS user";
    extraGroups  = [ "networkmanager" "wheel" "docker" "video" "seat" "audio" "libvirtd" ];
    password     = "steamos";
  };

  #################
  # Security      #
  #################
  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable           = true;
  services.seatd.enable            = true;

  #################
  # HIP           #
  #################
  systemd.tmpfiles.rules = 
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  #################
  # LACT          #
  # Linux AMD GPU controller #
  #################
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

  #################
  # Plasma        #
  #################
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };
}

