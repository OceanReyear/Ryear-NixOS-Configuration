{ lib, ... }:

{
  programs.plasma = {
    enable = true;

    # 显示器配置 (KScreen)
    kscreen = {
      enable = true;
      outputs = {
        eDP-1 = {
          enable = true;
          mode = "3072x1920@120.00";  # 3K 分辨率 120Hz
          scale = 2.0;                 # 200% 缩放
          position = "0,0";
          primary = true;
        };
      };
    };

    # 其他 Plasma 配置可以在这里添加
    # 例如：面板、快捷键、窗口规则等
  };
}