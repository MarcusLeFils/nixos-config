# hardware-configuration.zeus.nix
# ===============================
# Zeus (OVH VPS) hardware config. Run `nixos-generate-config` on Zeus
# to produce the real version, then replace this stub.
{ lib, ... }: {
  imports = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Adjust to real device
  # boot.initrd.availableKernelModules = [ ... ];
  # boot.kernelModules = [ ... ];
  # fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}