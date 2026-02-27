{ config, lib, pkgs, ... }:

{
  # ============================================
  # Btrfs 文件系统配置
  # ============================================

  boot.initrd.supportedFilesystems = [ "btrfs" ];

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:3" "noatime" "discard=async" "space_cache=v2" ];
    };
    
    "/home" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd:3" "noatime" "discard=async" "space_cache=v2" ];
    };
    
    "/nix" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd:3" "noatime" "discard=async" "space_cache=v2" ];
    };
    
    "/var/log" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@log" "compress=zstd:3" "noatime" "discard=async" "space_cache=v2" ];
    };
    
    "/vms" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@vms" "noatime" "discard=async" "space_cache=v2" ];
    };
  };

  # 设置 /vms 的 NoCOW 属性
  system.activationScripts.vms-nocow = {
    deps = [ "specialfs" ];
    text = ''
      if [ -d /vms ]; then
        ${pkgs.e2fsprogs}/bin/chattr +C /vms 2>/dev/null || true
      fi
    '';
  };

  # Btrfs 自动清理
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" "/home" ];
  };
}
