# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../mixins/postgres/postgres-service.nix
      ../../mixins/java-env.nix
    ];

  # Use the GRUB 2 boot loader.
  virtualisation.virtualbox.guest.enable = true;
  boot.initrd.checkJournalingFS = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "ga";
  # networking.proxy.default = "http://sun-web-intdev.ga.gov.au:2710";
  networking.proxy.default = "http://localhost:3128";

  time.timeZone = "Australia/Canberra";

  nixpkgs.config = import ../../nixpkgs-config.nix;

  # Set SSL_CERT_FILE, so that nix-shell doesn't make it up.
  # See https://github.com/NixOS/nixpkgs/issues/13744.
  environment.variables."SSL_CERT_FILE" = "/etc/ssl/certs/ca-bundle.crt";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    systemToolsEnv
    pythonEnv
    squirrelsql
  ];

  # Use your own CNTLM. Set username to your u-number
  # and put your password into /etc/cntlm.password.
  # Remember to 'chmod 0600 /etc/cntlm.password'.

  # services.cntlm = {
  #   enable = true;
  #   username = "your windows u-number";
  #   domain = "PROD";
  #   password = import /etc/cntlm.password;
  #   proxy = ["proxy.ga.gov.au:8080"];
  #   port = [3128];
  #   netbios_hostname = "127.0.0.1";
  # };

  services.openssh.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.tomcat = {
    enable = true;
    package = pkgs.tomcat8;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define your user account. Don't forget to set your password with ‘sudo passwd username’.
  # users.extraUsers.username = {
  #    isNormalUser = true;
  #    uid = 1000;
  #    extraGroups = [ "wheel" "tomcat" ];
  # };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
  system.autoUpgrade.enable = true;
}
