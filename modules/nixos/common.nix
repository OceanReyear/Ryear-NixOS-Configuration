{ lib, pkgs, ... }:
{
  imports = [
    ./backup.nix
  ];

  # ============================================
  # 快照管理（Snapper）
  # ============================================

  services.snapper = {
    configs = {
      root = {
        SUBVOLUME = "/";
        filesystem = "btrfs";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = "3";
        TIMELINE_LIMIT_DAILY = "7";
        TIMELINE_LIMIT_WEEKLY = "4";
        TIMELINE_LIMIT_MONTHLY = "12";
        cleanup = "timeline";
        prePostEnable = true;
        exclude = [ "/vms" "/swap" "/tmp" "/var/tmp" "/var/cache" ];
      };

      home = {
        SUBVOLUME = "/home";
        filesystem = "btrfs";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = "3";
        TIMELINE_LIMIT_DAILY = "7";
        TIMELINE_LIMIT_WEEKLY = "4";
        exclude = [ "/swap" ];
        cleanup = "timeline";
      };
    };
  };

  services.snapper.cleanupInterval = "1d";

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # ============================================
  # 系统基础配置
  # ============================================

  system.stateVersion = "25.11";
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # ============================================
  # 引导与内核
  # ============================================

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      configurationLimit = 10;
    };
  };

  zramSwap = {
    enable = true;
    memoryMax = 8 * 1024 * 1024 * 1024;
  };

  # ============================================
  # Nix 包管理器与 Generation 深度配置
  # ============================================

  nix = {
    gc = {
      automatic = true;
      dates = "23:30";
      options = "--delete-older-than 7d --max-freed 10G";
      persistent = true;
    };
    optimise = {
      automatic = true;
      dates = [ "23:35" ];
    };
    settings = {
      max-jobs = lib.mkDefault "auto";
      cores = lib.mkDefault 0;
      connect-timeout = 10;
      stalled-download-timeout = 90;
      keep-derivations = true;
      keep-outputs = true;
      sandbox = true;
      substituters = [
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "mirrors.tuna.tsinghua.edu.cn-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      extra-experimental-features = [ "nix-command" "flakes" ];
    };
  };

  system.autoUpgrade.enable = false;

  # ============================================
  # 网络配置
  # ============================================

  networking.networkmanager.enable = true;

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # ============================================
  # 桌面环境
  # ============================================

  programs.zsh.enable = true;

  services.displayManager.sddm = {
    enable = true;
    settings = {
      General = {
        theme = "breeze";
        background = "/etc/sddm/wallpapers/bg.png";
      };
    };
  };

  # 复制壁纸到 /etc 目录供 SDDM 使用
  environment.etc."sddm/wallpapers/bg.png".source = ../../assets/bg.png;

  services.desktopManager.plasma6.enable = true;

  hardware.bluetooth.enable = true;

  # ============================================
  # 容器与虚拟机
  # ============================================

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    daemon.settings = {
      "registry-mirrors" = [ "https://docker.mirrors.tuna.tsinghua.edu.cn" ];
      "data-root" = "/vms/data/docker";
    };
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  services.mysql.package = pkgs.mysql;
  services.mysql.dataDir = "/vms/data/mysql";

  services.postgresql.dataDir = "/vms/data/postgresql";

  fileSystems."/var/lib/libvirt/images" = {
    device = "/vms/libvirt/images";
    options = [ "bind" ];
  };

  systemd.tmpfiles.rules = [
    "d /vms/backup 0755 root root -"
    "d /vms/backup/nixos-config 0755 root root -"
    "d /vms/libvirt/images 0755 qemu-libvirtd qemu-libvirtd -"
    "d /vms/libvirt/iso 0755 reyear users -"
    "d /vms/libvirt/vms 0755 reyear users -"
    "d /vms/data 0755 root root -"
    "d /vms/data/docker 0711 root root -"
    "d /vms/data/postgresql 0700 postgres postgres -"
    "d /vms/data/mysql 0700 mysql mysql -"
  ];

  # ============================================
  # 用户配置
  # ============================================

  users.users.reyear = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" "libvirtd" "kvm" ];
    hashedPassword = "$6$IU4/Z3jWlSxOSOCu$8J2EiRmj/hUhwVzCUP/.DQQQx.NDH3qn2TIchEGl5IIamI10Zwg5mP4f5jak14AYjYhrqpFs.vTgWi6N0VaV7.";
    home = "/home/reyear";
    createHome = true;
    shell = pkgs.zsh;
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
    nerd-fonts.jetbrains-mono
    proggyfonts
  ];

  # ============================================
  # 系统软件包
  # ============================================

  environment.systemPackages = with pkgs; [
    throne
    opencode
    compsize
    btrfs-assistant
    snapper
    btdu
    docker-compose
  ];

  nixpkgs.config.allowUnfree = true;
}
