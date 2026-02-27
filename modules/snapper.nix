{ config, lib, pkgs, ... }:

{
  # ============================================
  # Snapper 快照管理配置
  # ============================================

  services.snapper = {
    configs = {
      root = {
        SUBVOLUME = "/";
        filesystem = "btrfs";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = "10";
        TIMELINE_LIMIT_DAILY = "14";
        TIMELINE_LIMIT_WEEKLY = "8";
        TIMELINE_LIMIT_MONTHLY = "12";
        TIMELINE_LIMIT_YEARLY = "3";
        cleanup = "timeline";
        prePostEnable = true;
        exclude = [ "/vms" "/tmp" "/var/tmp" "/var/cache" "/nix" "/home/.snapshots" ];
      };

      home = {
        SUBVOLUME = "/home";
        filesystem = "btrfs";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = "5";
        TIMELINE_LIMIT_DAILY = "7";
        TIMELINE_LIMIT_WEEKLY = "4";
        TIMELINE_LIMIT_MONTHLY = "6";
        TIMELINE_LIMIT_YEARLY = "2";
        cleanup = "timeline";
        exclude = [ "/home/*/.cache" "/home/*/.local/share/Trash" ];
      };
    };
  };

  # 每天清理一次旧快照
  services.snapper.cleanupInterval = "1d";
}
