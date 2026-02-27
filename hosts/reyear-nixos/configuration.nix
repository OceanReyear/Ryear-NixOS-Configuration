{ config, lib, pkgs, inputs, ... }:

{
  # ============================================
  # NixOS 主配置文件 - 模块化入口
  # ============================================

  # 导入硬件配置（自动生成，不要修改）
  imports = [
    ./hardware-configuration.nix
    
    # 功能模块
    ../../modules/btrfs.nix
    ../../modules/boot.nix
    ../../modules/desktop.nix
    ../../modules/network.nix
    ../../modules/nix.nix
    ../../modules/users.nix
    ../../modules/security.nix
    ../../modules/snapper.nix
    ../../modules/fonts.nix
    
    # Home Manager 模块（将在步骤5启用）
    # inputs.home-manager.nixosModules.home-manager
  ];

  # ============================================
  # 系统基础配置（保留在入口文件中的核心配置）
  # ============================================

  # 系统版本标识
  system.stateVersion = "25.11";

  # 时间配置
  time.timeZone = "Asia/Shanghai";

  # 控制台配置
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ============================================
  # 全局环境变量
  # ============================================

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
    PAGER = "less";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
  };

  # ============================================
  # 系统软件包（基础工具，具体包在 home-manager 中管理）
  # ============================================

  environment.systemPackages = with pkgs; [
    # 系统管理工具
    vim
    wget
    curl
    git
    htop
    btop
    nvtop
    lm_sensors
    
    # 文件工具
    rsync
    unzip
    unrar
    p7zip
    ripgrep
    fd
    fzf
    
    # 网络工具
    nmap
    tcpdump
    wireshark
    iperf3
    
    # 开发基础
    gcc
    gnumake
    cmake
    pkg-config
    python3
    nodejs_22
    go
    rustup
    
    # 系统工具
    nix-output-monitor
    nvd
    compsize
    btrfs-assistant
    snapper
    btdu
    smartmontools
    usbutils
    pciutils
    
    # 压缩与加密
    gnupg
    pinentry
    age
    sops
    
    # 终端工具
    alacritty
    tmux
    neofetch
    onefetch
    fastfetch
    
    # 版本控制
    git-absorb
    git-interactive-rebase-tool
    delta
    
    # 系统优化
    earlyoom
    irqbalance
    cpupower-gui
  ];

  # ============================================
  # 系统服务（基础服务）
  # ============================================

  services = {
    # 系统日志
    journald.extraConfig = "SystemMaxUse=1G";
    
    # 系统监控
    sysstat.enable = true;
    
    # 自动挂载
    udisks2.enable = true;
    gvfs.enable = true;
    
    # 定时任务
    cron.enable = true;
    
    # 早期 OOM 杀手
    earlyoom.enable = true;
    earlyoom.freeMemThreshold = 10;
    earlyoom.freeSwapThreshold = 10;
  };

  # ============================================
  # 系统优化
  # ============================================

  # 内核参数优化
  boot.kernel.sysctl = {
    # 虚拟内存优化
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    # 文件系统缓存
    "vm.page-cluster" = 3;
  };

  # ============================================
  # 开发环境工具
  # ============================================

  programs = {
    # direnv（环境自动加载）
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
    };
    
    # 命令行增强
    bash.enableCompletion = true;
    fish.enable = false;  # 如果需要 fish 可以启用
    
    # 开发工具
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };
    
    # 终端复用
    tmux = {
      enable = true;
      shortcut = "a";
      terminal = "screen-256color";
      extraConfig = ''
        set -g mouse on
        set -g status-right "#[fg=white]%Y-%m-%d %H:%M:%S"
      '';
    };
  };

  # ============================================
  # 包管理器配置
  # ============================================

  nixpkgs.config = {
    # 允许非自由软件
    allowUnfree = true;
    # 允许损坏包（某些旧包可能需要）
    allowBroken = false;
    # 包覆盖（自定义包版本）
    packageOverrides = pkgs: {
      # 示例：自定义包版本
      # myPackage = pkgs.callPackage ./packages/my-package.nix {};
    };
  };

  # ============================================
  # 系统健康检查（每周执行）
  # ============================================

  systemd.timers.system-health-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  systemd.services.system-health-check = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      #!/bin/sh
      echo "=== NixOS 系统健康检查 $(date) ==="
      echo ""
      
      # 1. 检查磁盘空间
      echo "1. 磁盘空间使用情况："
      df -h / /home /nix /boot
      echo ""
      
      # 2. 检查 Btrfs 健康
      echo "2. Btrfs 文件系统状态："
      ${pkgs.btrfs-progs}/bin/btrfs filesystem show /
      ${pkgs.btrfs-progs}/bin/btrfs device stats / | grep -v " 0$" || echo "所有设备正常"
      echo ""
      
      # 3. 检查快照数量
      echo "3. Snapper 快照统计："
      if [ -f /etc/snapper/configs/root ]; then
        ROOT_SNAPS=$(sudo snapper -c root list | wc -l)
        echo "根目录快照数量：$((ROOT_SNAPS - 2))个"
      fi
      if [ -f /etc/snapper/configs/home ]; then
        HOME_SNAPS=$(sudo snapper -c home list | wc -l)
        echo "家目录快照数量：$((HOME_SNAPS - 2))个"
      fi
      echo ""
      
      # 4. 检查 Nix 存储
      echo "4. Nix 存储使用情况："
      du -sh /nix/store 2>/dev/null || echo "无法访问 /nix/store"
      echo ""
      
      # 5. 检查系统服务
      echo "5. 关键服务状态："
      systemctl is-active networkmanager && echo "✅ NetworkManager: 运行中"
      systemctl is-active sshd && echo "✅ SSH: 运行中"
      systemctl is-active sddm && echo "✅ SDDM: 运行中"
      echo ""
      
      # 6. 检查系统更新
      echo "6. 系统更新状态："
      nix-channel --list
      echo ""
      
      echo "=== 健康检查完成 ==="
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
