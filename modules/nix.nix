{ config, lib, pkgs, ... }:

{
  # ============================================
  # Nix 包管理器与 Generation 深度配置
  # ============================================

  nix = {
    # 启用 flakes 和 nix-command
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      auto-optimise-store = true;
      warn-dirty = false;
      keep-derivations = true;
      keep-outputs = true;
      sandbox = true;
      trusted-users = [ "root" "reyear" ];
      
      # 性能优化
      max-jobs = "auto";
      cores = 0;
      connect-timeout = 10;
      stalled-download-timeout = 90;
      
      # 镜像源（使用清华大学镜像）
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "mirrors.tuna.tsinghua.edu.cn-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    
    # 垃圾回收配置
    gc = {
      automatic = true;
      dates = "23:30";  # 每晚 23:30 执行
      options = "--delete-older-than 14d --max-freed 50G";  # 基于您1.9TB空间优化
      persistent = true;
    };
    
    # 存储优化
    optimise = {
      automatic = true;
      dates = [ "23:35" ];  # 每晚 23:35 执行，紧跟 GC 之后
    };
    
    # 启用 nix-command 和 flakes
    nixPath = [ "nixpkgs=/etc/nixos/flake.nix" ];
  };

  # 禁用自动系统升级（保持手动控制）
  system.autoUpgrade.enable = false;
  system.autoUpgrade.allowReboot = false;

  # 定期更新 nixpkgs 通道（可选）
  # system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.11";
}
