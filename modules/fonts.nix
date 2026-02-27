{ config, lib, pkgs, ... }:

{
  # ============================================
  # 字体与输入法配置
  # ============================================

  # 系统字体
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # 基础字体
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      
      # 等宽字体（编程用）
      jetbrains-mono
      fira-code
      fira-code-symbols
      cascadia-code
      source-code-pro
      
      # 中文字体
      wqy_zenhei
      wqy_microhei
      source-han-sans
      source-han-serif
      
      # 英文字体
      liberation_ttf
      dejavu_fonts
      corefonts  # Microsoft 核心字体
      
      # 符号字体
      font-awesome
      material-icons
      nerd-fonts  # 包含大量图标字体
      
      # 其他实用字体
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      ubuntu_font_family
    ];
    
    # 字体配置
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK SC" "Noto Serif" "DejaVu Serif" ];
        sansSerif = [ "Noto Sans CJK SC" "Noto Sans" "DejaVu Sans" ];
        monospace = [ "JetBrains Mono" "Fira Code" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };

  # 输入法配置
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "zh_TW.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
    };
    
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime           # Rime 输入法引擎
        fcitx5-chinese-addons # 中文附加组件
        fcitx5-configtool     # 配置工具
        fcitx5-gtk            # GTK 支持
        fcitx5-qt             # Qt 支持
        fcitx5-table-extra    # 额外输入法表
        # fcitx5-pinyin-moegirl # 萌娘百科词库（可选）
        # fcitx5-pinyin-zhwiki  # 维基百科词库（可选）
      ];
    };
  };

  # 输入法环境变量
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";  # 某些游戏需要
  };

  # 输入法自动启动
  services.xserver.displayManager.sessionCommands = ''
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    fcitx5 &
  '';
}
