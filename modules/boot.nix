{ config, lib, pkgs, ... }:

{
  # ============================================
  # 引导与内核配置
  # ============================================

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/bc1d9eea-3661-4cf9-b50e-8c3580ff1f7e";
    allowDiscards = true;
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      configurationLimit = 15;  # 增加到15个，给您更多回滚空间
      extraEntries = ''
        menuentry "Windows 11" {
          insmod part_gpt
          insmod fat
          insmod chain
          search --fs-uuid --set=root F460-AA93
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
      # 使用 systemd-boot 主题
      useOSProber = false;
      theme = pkgs.sleek-grub-theme.override {
        withStyle = "dark";
        withBanner = "Welcome to NixOS";
      };
    };
  };

  # 启用早期启动的微码更新
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # 内核参数优化
  boot.kernelParams = [
    "quiet"
    "splash"
    "mitigations=off"  # 性能优化，根据安全需求调整
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.max_pool_percent=20"
  ];

  # 启用 ZRAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;
}
