{ config, lib, pkgs, inputs, ... }:

let
  resumeOffset = "14427392";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================
  # Btrfs 优化配置（强制覆盖 hardware-configuration.nix）
  # ============================================

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd:3" "noatime" "discard=async" ];
    };
    
    "/home" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd:3" "noatime" "discard=async" ];
    };
    
    "/nix" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd:3" "noatime" "discard=async" ];
    };
    
    "/var/log" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@log" "compress=zstd:3" "noatime" "discard=async" ];
    };

    "/var/backup" = lib.mkForce {
      device = "/vms/backup";
      fsType = "none";
      options = [ "bind" ];
    };
    
    "/vms" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@vms" "noatime" "discard=async" ];
    };

    "/swap" = lib.mkForce {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@swap" "noatime" "discard=async" "nodatacow" "compress=no" ];
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

  system.activationScripts.swap-nocow = {
    deps = [ "specialfs" ];
    text = ''
      if [ -d /swap ]; then
        ${pkgs.e2fsprogs}/bin/chattr +C /swap 2>/dev/null || true
        [ -f /swap/swapfile ] && ${pkgs.e2fsprogs}/bin/chattr +C /swap/swapfile 2>/dev/null || true
      fi
    '';
  };

  system.activationScripts.resume-offset-check = {
    deps = [ "specialfs" ];
    text = ''
      if [ -f /swap/swapfile ]; then
        expected="${resumeOffset}"
        actual="$(${pkgs.btrfs-progs}/bin/btrfs inspect-internal map-swapfile -r /swap/swapfile 2>/dev/null || true)"
        if [ -n "$actual" ] && [ "$actual" != "$expected" ]; then
          echo "Warning: resume_offset mismatch. Expected $expected, got $actual." >&2
          echo "Run: btrfs inspect-internal map-swapfile -r /swap/swapfile and update boot.kernelParams." >&2
        fi
      fi
    '';
  };

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
  networking.hostName = "reyear-nixos";
  time.timeZone = "Asia/Shanghai";

  # ============================================
  # 引导与内核
  # ============================================


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

  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=${resumeOffset}" ];

  # ============================================
  # Swap 配置（40GB swapfile）
  # ============================================

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 40 * 1024;
    }
  ];

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
      dates = "23:30";  # 每晚 23:30 执行
      options = "--delete-older-than 7d --max-freed 10G";
      persistent = true;
    };
    optimise = {
      automatic = true;
      dates = [ "23:35" ];  # 每晚 23:35 执行，紧跟 GC 之后
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

  services.displayManager.sddm.enable = true;
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
    proggyfonts
  ];

  # ============================================
  # 系统软件包
  # ============================================

  nix.settings.extra-experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    throne
    opencode
    compsize
    btrfs-assistant
    snapper
    btdu
    docker-compose
    qqmusic
  ];


  nixpkgs.config.allowUnfree = true;

  # ============================================
  # 备份与灾难恢复
  # ============================================

  systemd.services.nixos-config-backup = {
    description = "Backup NixOS configuration";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:${pkgs.coreutils}/bin:${pkgs.rsync}/bin:$PATH"

      BACKUP_DIR="/var/backup/nixos-config"
      SSH_DIR="/home/reyear/.ssh"
      IDENTITY_FILE="$SSH_DIR/id_ed25519"
      KNOWN_HOSTS="$SSH_DIR/known_hosts"

      mkdir -p "$BACKUP_DIR"
      ${pkgs.rsync}/bin/rsync -a --delete /etc/nixos/ "$BACKUP_DIR/"

      if [ -d /etc/nixos/.git ]; then
        cd /etc/nixos

        current_url="$(${pkgs.git}/bin/git -c safe.directory=/etc/nixos remote get-url origin 2>/dev/null || true)"
        case "$current_url" in
          https://github.com/*)
            ${pkgs.git}/bin/git -c safe.directory=/etc/nixos remote set-url origin \
              git@github.com:OceanReyear/Ryear-NixOS-Configuration.git
            ;;
        esac

        if [ -f "$IDENTITY_FILE" ]; then
          export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i $IDENTITY_FILE -o UserKnownHostsFile=$KNOWN_HOSTS -o StrictHostKeyChecking=accept-new"
        fi

        ${pkgs.git}/bin/git -c safe.directory=/etc/nixos config user.name "reyear"
        ${pkgs.git}/bin/git -c safe.directory=/etc/nixos config user.email "reyearocean@qq.com"
        ${pkgs.git}/bin/git -c safe.directory=/etc/nixos add -A
        if ! ${pkgs.git}/bin/git -c safe.directory=/etc/nixos diff --cached --quiet; then
          ${pkgs.git}/bin/git -c safe.directory=/etc/nixos -c user.name="reyear" -c user.email="reyearocean@qq.com" \
            commit -m "nixos-backup: $(date '+%Y-%m-%d %H:%M:%S')"
          ${pkgs.git}/bin/git -c safe.directory=/etc/nixos push origin main 2>&1 || echo "Git push failed"
        fi
      fi
    '';
  };

  systemd.timers.nixos-config-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "10min";
    };
  };
}
