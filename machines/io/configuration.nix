{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = false;

  boot.loader = {
    timeout = 1;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # See: github.com/NixOS/nixpkgs/issues/22470
  boot.earlyVconsoleSetup = true;

  # https://github.com/NixOS/nixpkgs/issues/22472
  boot.kernelParams = ["systemd.legacy_systemd_cgroup_controller=yes"];

  boot.initrd.checkJournalingFS = false;

  virtualisation.docker.enable = true;

  # Virtual box host breaks sound and suspend
  virtualisation.virtualbox.host.enable = true;

  networking = {
    hostName = "io";
    wireless.enable = true;

    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "wlp4s0";
    };
    extraHosts =
    ''
      192.168.1.2 imac
    '';
  };

  networking.proxy.default = "http://proxy.inno.lan:3128";

  time.timeZone = "Australia/Sydney";

  nix = {
    # nixPath = [ "/home/lbodor/dev" "nixos-config=/etc/nixos/configuration.nix" ];
    binaryCaches = [ https://cache.nixos.org http://hydra.cryp.to ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.cryp.to-1:8g6Hxvnp/O//5Q1bjjMTd5RO8ztTsG8DKPOAg9ANr2g="
    ];
  };

  nixpkgs.config = import ../../nixpkgs-config.nix;

  # Set SSL_CERT_FILE, so that nix-shell doesn't make it up.
  # See https://github.com/NixOS/nixpkgs/issues/13744.
  environment.variables."SSL_CERT_FILE" = "/etc/ssl/certs/ca-bundle.crt";

  environment.systemPackages = with pkgs; [
    systemToolsEnv
    awsEnv
    javaEnv
    dmenu
    haskellPackages.X11
    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    xorg.xbacklight
    squirrelsql
    slack
    notify-osd
    neovim
    neovim-remote
    vivaldi
  ];

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      ubuntu_font_family
      unifont
    ];
  };

  programs = {
    bash.shellAliases = {
      "vi" = "nvim";
    };
    ssh.startAgent = true;
  };

  services.atd = {
    enable = true;
    allowEveryone = true;
  };

  services.upower.enable = true;
  services.locate.enable = true;

  services.xserver = {
    enable = true;
    synaptics.enable = true;
    synaptics.minSpeed = "1";
    synaptics.palmDetect = true;
    synaptics.twoFingerScroll = true;
    xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
  };

  services.tomcat = {
    enable = false;
    package = pkgs.tomcat8;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.extraUsers.lbodor = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/lbodor";
    description = "Lazar Bodor";
    extraGroups = [ "docker" "tomcat" "wheel" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
  system.autoUpgrade = {
    enable = true;
    dates = "11:24";
  };
}
