{ config, lib, pkgs, ... }:

{
  # ============================================
  # 安全增强配置
  # ============================================

  # 系统安全基线
  security = {
    

    # 内核安全模块
    lockKernelModules = false;  # 开发时建议禁用

    # 虚拟化安全
    virtualisation = {
      # 启用虚拟机支持
      libvirtd.enable = true;
      # 启用 Docker
      docker.enable = true;
      # 启用 Podman
      podman.enable = false;  # 与 Docker 二选一
    };

    # 访问控制列表
    acme = {
      defaults.email = "reyearocean@qq.com";
      acceptTerms = true;
    };
  };

  # 系统服务安全配置
  systemd = {
    # 服务安全配置
    services = {
      # SSH 服务限制
      "sshd".serviceConfig = {
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
      };
    };

    # 系统范围的安全配置
    extraConfig = ''
      DefaultTimeoutStopSec=30s
      DefaultTimeoutStartSec=30s
      DefaultRestartSec=100ms
    '';
  };

  # 网络防火墙增强规则
  networking.firewall = {
    # 基础规则已在 network.nix 中配置
    # 这里添加额外的安全规则
    extraCommands = ''
      # 防止 ICMP 泛洪攻击
      iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT
      iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
      
      # 防止 SYN 泛洪攻击
      iptables -N SYN_FLOOD
      iptables -A SYN_FLOOD -m limit --limit 10/second --limit-burst 20 -j RETURN
      iptables -A SYN_FLOOD -j DROP
      iptables -A INPUT -p tcp --syn -j SYN_FLOOD
    '';
    extraStopCommands = ''
      iptables -F
      iptables -X SYN_FLOOD
    '';
  };

  # 日志安全配置
  services.journald = {
    extraConfig = ''
      # 限制日志大小
      SystemMaxUse=1G
      RuntimeMaxUse=200M
      MaxRetentionSec=1month
      # 转发到系统日志
      ForwardToSyslog=yes
    '';
  };

  # 审计与监控
  services.auditbeat = {
    enable = false;  # 需要时启用，可能影响性能
    settings = {
      auditbeat.config.modules = [
        {
          module = "auditd";
          resolve_ids = true;
          failure_mode = "log";
          backlog_limit = 8192;
          rate_limit = 0;
          include_raw_message = false;
          include_warnings = false;
          audit_rules = ''
            -a always,exit -F arch=b64 -S execve -k exec
          '';
        }
      ];
    };
  };

  # 定期安全扫描
  services.rkhunter = {
    enable = false;  # 需要时启用
    cron = {
      enable = false;
      at = "daily";
    };
  };

  # 备份脚本增强（原配置的优化版本）
  system.activationScripts.git-backup = {
    deps = [ "etc" ];
    text = ''
      export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:${pkgs.coreutils}/bin:${pkgs.rsync}/bin:$PATH"
      export HOME=/home/reyear
      
      SSH_DIR="/home/reyear/.ssh"
      IDENTITY_FILE="$SSH_DIR/id_ed25519"
      KNOWN_HOSTS="$SSH_DIR/known_hosts"
      
      # 创建本地备份
      mkdir -p /var/backup/nixos-config
      ${pkgs.rsync}/bin/rsync -a --delete /etc/nixos/ /var/backup/nixos-config/
      
      # 验证备份完整性
      if [ $? -eq 0 ]; then
        echo "$(date): Local backup successful" >> /var/log/nixos-backup.log
      else
        echo "$(date): Local backup failed" >> /var/log/nixos-backup.log
        exit 1
      fi
      
      cd /etc/nixos
      
      # 配置 Git
      export GIT_CONFIG_GLOBAL="/home/reyear/.gitconfig"
      ${pkgs.git}/bin/git config --file "$GIT_CONFIG_GLOBAL" user.name "reyear"
      ${pkgs.git}/bin/git config --file "$GIT_CONFIG_GLOBAL" user.email "reyearocean@qq.com"
      ${pkgs.git}/bin/git config --file "$GIT_CONFIG_GLOBAL" --add safe.directory /etc/nixos
      
      # 设置 SSH 权限
      if [ -d "$SSH_DIR" ]; then
        chown reyear:users "$SSH_DIR" 2>/dev/null || true
        chmod 700 "$SSH_DIR" 2>/dev/null || true
        [ -f "$IDENTITY_FILE" ] && chmod 600 "$IDENTITY_FILE" 2>/dev/null || true
        [ -f "$KNOWN_HOSTS" ] && chmod 600 "$KNOWN_HOSTS" 2>/dev/null || true
      fi
      
      # 设置 SSH 命令
      export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i $IDENTITY_FILE -o UserKnownHostsFile=$KNOWN_HOSTS -o StrictHostKeyChecking=accept-new"
      
      # 检查网络连接
      if ping -c 1 -W 2 github.com >/dev/null 2>&1; then
        ${pkgs.git}/bin/git add -A
        if ! ${pkgs.git}/bin/git diff --cached --quiet; then
          COMMIT_MSG="nixos-rebuild: $(date '+%Y-%m-%d %H:%M:%S') - Kernel: $(uname -r) - Host: $(hostname)"
          if ${pkgs.git}/bin/git commit -m "$COMMIT_MSG"; then
            if ${pkgs.git}/bin/git push origin main 2>&1; then
              echo "$(date): Git backup successful" >> /var/log/nixos-backup.log
            else
              echo "$(date): Git push failed, will retry next time" >> /var/log/nixos-backup.log
            fi
          fi
        fi
      else
        echo "$(date): No network connection, skipping Git push" >> /var/log/nixos-backup.log
      fi
    '';
  };
}
