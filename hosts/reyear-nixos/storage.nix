{ lib, pkgs, ... }:
let
  btrfsDevice = "/dev/mapper/cryptroot";
  commonMountOptions = [ "compress=zstd:3" "noatime" "discard=async" ];
  btrfsSubvolumes = {
    "/" = "@";
    "/home" = "@home";
    "/nix" = "@nix";
    "/var/log" = "@log";
    "/vms" = "@vms";
    "/swap" = "@swap";
  };
  mkBtrfsSubvolume = mountPoint: subvol:
    let
      extraOptions = if mountPoint == "/swap" then [ "nodatacow" "compress=no" ] else [ ];
    in {
      device = btrfsDevice;
      fsType = "btrfs";
      options = [ "subvol=${subvol}" ] ++ commonMountOptions ++ extraOptions;
    };
in {
  # Host-specific btrfs subvolume mount table; add/remove subvolumes here.
  fileSystems = (builtins.mapAttrs (
    mountPoint: subvol: lib.mkOverride 0 (mkBtrfsSubvolume mountPoint subvol)
  ) btrfsSubvolumes) // {
    "/var/backup" = {
      device = "/vms/backup";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  boot.initrd.luks.devices."cryptroot".allowDiscards = true;

  # Swap file on /swap subvolume (host-specific layout).
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 40 * 1024;
    }
  ];

  # 设置 /vms 的 NoCOW 属性
  system.activationScripts.vms-nocow = {
    deps = [ "specialfs" ];
    text = ''
      if [ -d /vms ]; then
        ${pkgs.e2fsprogs}/bin/chattr +C /vms 2>/dev/null || true
      fi
    '';
  };

  system.activationScripts.swap-nocow = {
    deps = [ "specialfs" ];
    text = ''
      if [ -d /swap ]; then
        ${pkgs.e2fsprogs}/bin/chattr +C /swap 2>/dev/null || true
        [ -f /swap/swapfile ] && ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile 2>/dev/null || true
      fi
    '';
  };
}
