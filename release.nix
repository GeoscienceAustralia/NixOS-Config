# origin: https://github.com/NixOS/nixpkgs/blob/ea9d390c1af028dcb8dfc630095ae7caafeba135/nixos/release.nix

{

# A bootable VirtualBox virtual appliance as an OVA file (i.e., packaged OVF).
ova =
  let
    evalConfig = import <nixpkgs/nixos/lib/eval-config.nix>;
    # makeDiskImage = import <nixpkgs/nixos/lib/make-disk-image.nix>;
    makeDiskImage = import ./make-disk-image.nix;

    config = (evalConfig {
      modules = [
           <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
          ./machines/ga/configuration.nix
        ];
    }).config;

  in
    with (import <nixpkgs> {}); makeDiskImage {
      inherit pkgs lib config;

      name = "nixos-ova-${config.system.nixosLabel}-${pkgs.stdenv.system}";
      diskSize = 100 * 1024; # MiB

      postVM =
        ''
          echo "creating VirtualBox disk image..."
          ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -O vdi $diskImage disk.vdi
          rm $diskImage

          echo "creating VirtualBox VM..."
          export HOME=$PWD
          export PATH=${pkgs.virtualbox}/bin:$PATH
          vmName="NixOS ${config.system.nixosLabel} (${pkgs.stdenv.system})"
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
            --medium disk.vdi
          VBoxManage modifyvm "$vmName" --natpf1 "guestssh,tcp,,4022,,22"

          echo "exporting VirtualBox VM..."
          mkdir -p $out
          fn="$out/nixos-${config.system.nixosLabel}-${pkgs.stdenv.system}.ova"
          VBoxManage export "$vmName" --output "$fn"
        '';
    };
}
