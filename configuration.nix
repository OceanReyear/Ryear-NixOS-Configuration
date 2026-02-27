{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================
  # 系统基础配置
  # ============================================

  system.stateVersion = "25.11";

  # 主机名
  networking.hostName = "reyear-nixos";

  # 时区（默认 UTC，如需修改取消注释并修改）
  # time.timeZone = "Asia/Shanghai";

  # ============================================
  # 引导与内核
  # ============================================

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # LUKS 全盘加密
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/bc1d9eea-3661-4cf9-b50e-8c3580ff1f7e";
    allowDiscards = true;
  };

  # GRUB 引导（UEFI + Windows 双启动）
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      # Generation 保留策略：启动菜单显示最近10个
      configurationLimit = 10;
      extraEntries = ''
        menuentry "Windows 11" {
          insmod part_gpt
          insmod fat
          insmod chain
          search --fs-uuid --set=root F460-AA93
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };

  # ============================================
  # Nix 包管理器与 Generation 深度配置
  # ============================================

  nix = {
    # 自动垃圾回收
    gc = {
      automatic = true;
      # 每周日凌晨2点执行
      dates = "Sun 02:00";
      # 保留策略：删除超过7天的 generation，但最多只释放10GB空间
      options = "--delete-older-than 7d --max-freed 10G";
      persistent = true;
    };

    # 优化 Nix store（去重整理）
    optimise = {
      automatic = true;
      dates = [ "03:00" ];
    };

    settings = {
      # 并行构建
      max-jobs = lib.mkDefault "auto";
      cores = lib.mkDefault 0;

      # 下载超时优化
      connect-timeout = 10;
      stalled-download-timeout = 90;

      # 缓存加速重建
      keep-derivations = true;
      keep-outputs = true;

      # 构建沙盒
      sandbox = true;

      # 镜像源配置
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "mirrors.tuna.tsinghua.edu.cn-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  # 禁用自动升级，手动控制 generation
  system.autoUpgrade.enable = lib.mkDefault false;

  # ============================================
  # 网络配置
  # ============================================

  networking.networkmanager.enable = true;

  # ============================================
  # 桌面环境
  # ============================================

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ============================================
  # 用户配置
  # ============================================

  users.users.reyear = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    hashedPassword = "$6$IU4/Z3jWlSxOSOCu$8J2EiRmj/hUhwVzCUP/.DQQQx.NDH3qn2TIchEGl5IIamI10Zwg5mP4f5jak14AYjYhrqpFs.vTgWi6N0VaV7.";
    # 【需要检查】确保你的用户目录存在，用于 SSH 密钥存储
    home = "/home/reyear";
    createHome = true;
  };

  # ============================================
  # 输入法
  # ============================================

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };

  # ============================================
  # 系统字体
  # ============================================

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    jetbrains-mono
    proggyfonts
  ];

  # ============================================
  # 系统软件包
  # ============================================

  environment.systemPackages = with pkgs; [
    # 基础工具
    vim
    wget
    git
    unzip
    unrar
    btop
    alacritty
    
    # 应用
    vscode
    obsidian
    firefox
    
    # Generation 管理工具
    nix-output-monitor
    nvd
  ];

  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  # ============================================
  # 备份与灾难恢复
  # ============================================

  # 方案1：完整备份到 ESP 分区（/boot）
  systemd.services.backup-nixos-config = {
    description = "Backup NixOS configuration to /boot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "backup-config" ''
        mkdir -p /boot/nixos-config-backup
        ${pkgs.rsync}/bin/rsync -a --delete /etc/nixos/ /boot/nixos-config-backup/
        # 确保 Git 仓库权限正确
        if [ -d /boot/nixos-config-backup/.git ]; then
          ${pkgs.coreutils}/bin/chmod -R +w /boot/nixos-config-backup/.git
        fi
      '';
    };
    wantedBy = [ "nixos-rebuild-switch.service" ];
  };

  # 方案2：Git 版本控制 + 自动推送到 GitHub
  systemd.services.nixos-config-git = {
    description = "Auto-commit and push NixOS configuration";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    

    path = [ pkgs.git pkgs.openssh ];
    
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/etc/nixos";
      # 使用 reyear 用户运行，确保能访问 ~/.ssh
      User = "reyear";
      Group = "users";
      
      ExecStart = pkgs.writeShellScript "git-commit-config" ''
        # 添加安全目录配置
        ${pkgs.git}/bin/git config --global --add safe.directory /etc/nixos
        
        # 【个人信息已写死】Git 配置
        GIT_USER_NAME="reyear"
        GIT_USER_EMAIL="reyearocean@qq.com"
        GIT_REPO="git@github.com:OceanReyear/Ryear-NixOS-Configuration.git"
        
        # 自动初始化（首次运行）
        if [ ! -d .git ]; then
          ${pkgs.git}/bin/git init
          ${pkgs.git}/bin/git config user.name "$GIT_USER_NAME"
          ${pkgs.git}/bin/git config user.email "$GIT_USER_EMAIL"
          ${pkgs.git}/bin/git remote add origin "$GIT_REPO"
          ${pkgs.git}/bin/git branch -M main
          echo "Git 仓库已初始化"
        fi
        
        # 确保配置正确（防止被覆盖）
        ${pkgs.git}/bin/git config user.name "$GIT_USER_NAME"
        ${pkgs.git}/bin/git config user.email "$GIT_USER_EMAIL"
        
        # 提交更改
        ${pkgs.git}/bin/git add -A
        ${pkgs.git}/bin/git diff --cached --quiet || {
          ${pkgs.git}/bin/git commit -m "nixos-rebuild: $(date '+%Y-%m-%d %H:%M:%S')"
          echo "配置已提交到本地仓库"
          
          # 推送到 GitHub（需要 SSH 密钥配置）
          ${pkgs.git}/bin/git push origin main 2>&1 && {
            echo "已成功推送到 GitHub"
          } || {
            echo "================================================"
            echo "⚠️  推送失败，请检查 SSH 配置："
            echo "1. 运行：ssh -T git@github.com"
            echo "2. 确保 /home/reyear/.ssh/id_ed25519 存在"
            echo "3. 公钥已添加到 GitHub: https://github.com/settings/keys"
            echo "================================================"
          }
        }
      '';
    };
    wantedBy = [ "nixos-rebuild-switch.service" ];
  };

  # 确保 SSH 目录权限正确
  systemd.tmpfiles.rules = [
    "d /home/reyear/.ssh 0700 reyear users -"
  ];
}
# Test automation
