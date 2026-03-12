{ pkgs, lib, wallpaper, taskbarIconPath, lockscreenWallpaper, ... }:

{
  programs.plasma = {
    enable = true;

    # ============================================
    # 壁纸配置
    # ============================================
    workspace.wallpaper = toString wallpaper;
    lockscreen.wallpaper = toString lockscreenWallpaper;

    # ============================================
    # 面板配置
    # ============================================

    panels = [
      # 底部主面板
      {
        location = "bottom";
        height = 40;
        hiding = "none";

        widgets = [
          # 左侧：应用启动器
          {
            kickoff = {
              icon = toString taskbarIconPath;
            };
          }
          # 虚拟桌面切换
          "org.kde.plasma.pager"
          # 任务管理器
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
                "applications:firefox.desktop"
                "applications:code.desktop"
              ];
            };
          }
          # 弹性空间
          "org.kde.plasma.panelspacer"
          # 系统托盘
          "org.kde.plasma.systemtray"
          # 时钟
          "org.kde.plasma.digitalclock"
          # 显示桌面
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    # ============================================
    # 桌面效果
    # ============================================

    workspace = {
      clickItemTo = "select";
      tooltipDelay = 500;
    };

    # 窗口管理效果
    kwin.titlebarButtons = {
      left = [ "on-all-desktops" "keep-above-windows" ];
      right = [ "help" "minimize" "maximize" "close" ];
    };

    # KWin 特效配置
    kwin.extraConfig = ''
      [Compositing]
      AnimationCurve=Linear
      AnimationDuration=200
      Backend=OpenGL
      GLCore=true
      OpenGLIsUnsafe=false

      [Effect-Blur]
      BlurStrength=8
      NoiseStrength=0

      [Effect-DesktopCube]
      AnimationDuration=500
      Opacity=0.8

      [Effect-Glide]
      AnimationDuration=200
      Invert=false

      [Effect-MagicLamp]
      AnimationDuration=200

      [Effect-SlideBack]
      SlideBack=true

      [Windows]
      AnimationDuration=200

      [Plugins]
      blurEnabled=true
      cubeEnabled=true
      glideEnabled=true
      magiclampEnabled=true
      slidebackEnabled=true
    '';
  };
}