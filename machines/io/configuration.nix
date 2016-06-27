{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../mixins/postgres/postgres-service.nix
    ];

  hardware.bluetooth.enable = false;

  boot.loader = {
    timeout = 1;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.initrd.checkJournalingFS = false;

  virtualisation.docker.enable = true;

  # Virtual box host breaks sound and suspend
  # virtualisation.virtualbox.host.enable = true;

  networking = {
    hostName = "io";
    wireless.enable = true;
  };

  time.timeZone = "Australia/Sydney";

  nix = {
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
    javaEnv
    pythonEnv
    cabal2nix
    dmenu
    haskellPackages.X11
    haskellPackages.xmobar
    haskellPackages.xmonad
    haskellPackages.xmonad-contrib
    haskellPackages.xmonad-extras
    xorg.xbacklight
    squirrelsql
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

  programs.ssh.startAgent = true;

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

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.extraUsers.lbodor = {
    uid = 1000;
    isNormalUser = true;
    home = "/home/lbodor";
    description = "Lazar Bodor";
    extraGroups = [ "docker" "wheel" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
