{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

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
              icon = "nix-snowflake";
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
  };

  # KWin 效果配置通过 kwriteconfig 实现
  # plasma-manager 目前不直接支持效果配置，需要使用额外配置
  home.file.".config/kwinrc" = {
    force = true;
    text = ''
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
      Cylinder=false
      Opacity=0.8

      [Effect-Glide]
      AnimationDuration=200
      Invert=false

      [Effect-MagicLamp]
      AnimationDuration=200

      [Effect-WobblyWindows]
      Drag=85
      MoveWindow=1
      Stiffness=15
      WobblynessLevel=1

      [Plugins]
      blurEnabled=true
      cubeEnabled=true
      glideEnabled=true
      magiclampEnabled=true
      wobblywindowsEnabled=true

      [Windows]
      AnimationDuration=200
    '';
  };
}