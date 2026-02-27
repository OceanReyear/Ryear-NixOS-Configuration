{ config, lib, pkgs, ... }:

{
  # ============================================
  # 桌面环境配置
  # ============================================

  # SDDM 显示管理器
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";  # Plasma 默认主题
  };

  # KDE Plasma 6 桌面环境
  services.desktopManager.plasma6.enable = true;

  # X11 兼容支持
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "";
    libinput.enable = true;  # 触摸板支持
  };

  # 混成器（Wayland 合成器）
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # 声音服务
  sound.enable = true;
  hardware.pulseaudio.enable = false;  # 使用 PipeWire 替代

  # 蓝牙
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  # 打印机支持
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # 自动挂载 USB 设备
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;

  # 电源管理
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;  # 与 power-profiles-daemon 冲突

  # 触摸板手势（Wayland）
  services.libinput.gestures = {
    enable = true;
    settings = {
      "gesture: swipe_edge" = {
        left = "command: 'swipe-left'";
        right = "command: 'swipe-right'";
        up = "command: 'swipe-up'";
        down = "command: 'swipe-down'";
      };
    };
  };
}
