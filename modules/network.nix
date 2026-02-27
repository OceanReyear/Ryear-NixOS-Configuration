{ config, lib, pkgs, ... }:

{
  # ============================================
  # 网络配置
  # ============================================

  # 基础网络配置
  networking = {
    hostName = "reyear-nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 22 ];  # HTTP, HTTPS, SSH
      allowedUDPPorts = [ 53 67 68 ];   # DNS, DHCP
      allowPing = true;
    };
    enableIPv6 = true;
  };

  # 时间同步
  services.timesyncd.enable = true;

  # mDNS（局域网设备发现）- 通过 avahi 实现
  # 注意：services 应该与 networking 同级，不在 networking 内部
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # 代理工具
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # 网络性能优化
  boot.kernel.sysctl = {
    # 增加 TCP 缓冲区大小
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    # 开启 TCP Fast Open
    "net.ipv4.tcp_fastopen" = 3;
    # 优化本地端口范围
    "net.ipv4.ip_local_port_range" = "1024 65535";
  };

  # 网络时间协议
  services.chrony.enable = false;  # 使用 systemd-timesyncd
}
