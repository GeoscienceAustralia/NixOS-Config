# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  user = {
    username = "guest";
    unumber = "u00000";
  };

in

{
  # make user available to included modules
  _module.args.user = user;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ../../mixins/postgres/postgres-service.nix
      # ../../mixins/java-env.nix
    ];

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.guest.enable = true;
  boot.initrd.checkJournalingFS = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "ga";
  networking.proxy.default = "http://sun-web-intdev.ga.gov.au:2710";
  # networking.proxy.default = "http://localhost:3128";

  time.timeZone = "Australia/Canberra";

  nixpkgs.config = import ../../nixpkgs-config.nix;

  # Set SSL_CERT_FILE, so that nix-shell doesn't make it up.
  # See https://github.com/NixOS/nixpkgs/issues/13744.
  # This is a problem only on 16.09pre and not on 16.03.
  # environment.variables."SSL_CERT_FILE" = "/etc/ssl/certs/ca-bundle.crt";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    systemToolsEnv
    slack
    # pythonEnv
    # squirrelsql
  ];

  # Use your own CNTLM. Set username to your u-number
  # and put your password into /etc/cntlm.password.
  # Remember to 'chmod 0600 /etc/cntlm.password'.

  # services.cntlm = {
  #   enable = true;
  #   username = user.unumber;
  #   domain = "PROD";
  #   password = import /etc/cntlm.password;
  #   proxy = ["proxy.ga.gov.au:8080"];
  #   port = [3128];
  #   netbios_hostname = "127.0.0.1";
  # };

  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # services.tomcat = {
  #   enable = true;
  #   package = pkgs.tomcat8;
  # };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define your user account. Don't forget to change your password.
  users.extraUsers = {
    ${user.username} = {
      password = "change-me";
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
    };
  };

  system.activationScripts = {
    dotfiles = pkgs.lib.stringAfter [ "users" ]
      ''
      # Import /etc/nixos/nixpkgs-config.nix from users private ~/.nixpkgs/config.nix
      # so that nix-env commands can find packages defined globally in nixpkgs-config.nix.
      if [ ! -e ~${user.username}/.nixpkgs/config.nix ]; then
        mkdir -p ~${user.username}/.nixpkgs
        cat > ~${user.username}/.nixpkgs/config.nix << EOF
      import /etc/nixos/nixpkgs-config.nix // {
        allowBroken = false;
      }
      EOF
      fi

      # Handover /etc/nixos to ${user.username}
      chown ${user.username}.users /etc/nixos
      '';
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
  system.autoUpgrade.enable = true;
}
