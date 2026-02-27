{ config, lib, pkgs, ... }:

{
  # ============================================
  # 用户与安全配置
  # ============================================

  # 主用户配置
  users.users.reyear = {
    isNormalUser = true;
    extraGroups = [
      "wheel"        # sudo 权限
      "networkmanager"
      "video"
      "audio"
      "docker"       # 预留 Docker 权限
      "libvirtd"     # 预留虚拟化权限
      "wireshark"    # 预留网络分析权限
      "scanner"      # 扫描仪权限
      "lp"           # 打印机权限
    ];
    # 密码哈希（保持您原来的密码）
    hashedPassword = "$6$IU4/Z3jWlSxOSOCu$8J2EiRmj/hUhwVzCUP/.DQQQx.NDH3qn2TIchEGl5IIamI10Zwg5mP4f5jak14AYjYhrqpFs.vTgWi6N0VaV7.";
    home = "/home/reyear";
    createHome = true;
    shell = pkgs.bash;
  };

  # 启用 sudo，配置为无密码（开发环境方便）
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;  # wheel 组成员无需密码
    extraConfig = ''
      # 保持日志记录
      Defaults logfile=/var/log/sudo.log
      Defaults log_input, log_output
      # 超时设置
      Defaults timestamp_timeout=30
    '';
  };

  # SSH 服务
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;  # 禁用密码登录
      PermitRootLogin = "no";          # 禁止 root SSH 登录
      X11Forwarding = true;
      AllowAgentForwarding = true;
      GatewayPorts = "no";
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Polkit 权限管理
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # 安全增强
  security = {
    # 强制访问控制（可选）
    apparmor.enable = false;  # 需要时启用
    # PAM 配置
    pam = {
      enable = true;
      services = {
        login = {
          # 登录时显示上次登录信息
          showMotd = true;
        };
      };
    };
    # 硬件安全模块
    # hsm.enable = false;  # 需要硬件支持
  };

  # 审计日志
  services.auditd.enable = false;  # 需要时启用，可能影响性能

  # 防火墙规则（已在 network.nix 中配置基础规则）
  # 这里可以添加应用特定规则
}
