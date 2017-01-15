# origin: https://github.com/NixOS/nixpkgs/blob/ea9d390c1af028dcb8dfc630095ae7caafeba135/nixos/release.nix

{ pwd }:

{

# A bootable VirtualBox virtual appliance as an OVA file (i.e., packaged OVF).
ova =
  let
    defaultPkgs = import <nixpkgs> {};
    nixpkgsCheckout = defaultPkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "9ab4d31";
      sha256 = "1nmcpfxi85kpkd906jj4m26bz8kxp47ijk2sswksypkyq22r83fw";
    };
    pinnedPkgs = import nixpkgsCheckout {};
    lib = pinnedPkgs.pkgs.lib;
    evalConfig = import (lib.concatStrings [nixpkgsCheckout "/nixos/lib/eval-config.nix"]);
    makeDiskImage = import ./make-disk-image.nix;

    config = (evalConfig {
      modules = [
           (lib.concatStrings [nixpkgsCheckout "/nixos/modules/installer/cd-dvd/channel.nix"])
          ./machines/ga/configuration.nix
        ];
    }).config;

    _nixosMachinesRev = pinnedPkgs.pkgs.runCommand "dummy" {} 
      ''
        mkdir $out
        cd ${pinnedPkgs.pkgs.copyPathToStore (toString pwd)}
        rev=$(${pinnedPkgs.pkgs.git}/bin/git rev-parse HEAD | cut -c -7)
        echo \"$rev\" > $out/rev.nix
      '';

    nixosMachinesRev = import (lib.concatStrings [_nixosMachinesRev "/rev.nix"]);

  in
    with pinnedPkgs; makeDiskImage {
      inherit pkgs lib config pwd;

      name = "nixos-ova-${nixosMachinesRev}-${pkgs.stdenv.system}";
      diskSize = 100 * 1024; # MiB

      postVM =
        ''
          export HOME=$PWD
          export PATH=${pkgs.virtualbox}/bin:$PATH

          echo "creating VirtualBox pass-through disk wrapper (no copying invovled)..."
          VBoxManage internalcommands createrawvmdk -filename disk.vmdk -rawdisk $diskImage

          echo "creating VirtualBox VM..."
          vmName="NixOS ${nixosMachinesRev} (${pkgs.stdenv.system})"
          VBoxManage createvm --name "$vmName" --register \
            --ostype ${if pkgs.stdenv.system == "x86_64-linux" then "Linux26_64" else "Linux26"}
          VBoxManage modifyvm "$vmName" \
            --memory 4096 --acpi on --vram 32 \
            ${lib.optionalString (pkgs.stdenv.system == "i686-linux") "--pae on"} \
            --nictype1 virtio --nic1 nat \
            --audiocontroller ac97 --audio alsa \
            --rtcuseutc on \
            --usb on --mouse usbtablet
          VBoxManage storagectl "$vmName" --name SATA --add sata --portcount 4 --bootable on --hostiocache on
          VBoxManage storageattach "$vmName" --storagectl SATA --port 0 --device 0 --type hdd \
            --medium disk.vmdk
          VBoxManage modifyvm "$vmName" --natpf1 "guestssh,tcp,,2222,,22"

          echo "exporting VirtualBox VM..."
          mkdir -p $out
          fn="$out/nixos-${nixosMachinesRev}-${pkgs.stdenv.system}.ova"
          vagrantBox="$out/nixos-${nixosMachinesRev}-${pkgs.stdenv.system}.box"
          VBoxManage export "$vmName" --output "$fn"

          ${pkgs.vagrant}/bin/vagrant package --base "$vmName" --vagrantfile ${./Vagrantfile} --out "$vagrantBox"
          rm -v $diskImage
        '';
    };
}
