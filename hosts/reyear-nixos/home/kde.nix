{ lib, pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    # 面板配置
    panels = [
      {
        location = "bottom";
        floating = true;  # 悬浮效果
        height = 48;

        widgets = [
          # 应用启动器
          {
            kickoff = {
              icon = "nix-snowflake-white";
            };
          }

          # 分隔符
          "org.kde.plasma.marginsseparator"

          # 任务管理器
          "org.kde.plasma.icontasks"

          # 分隔符
          "org.kde.plasma.marginsseparator"

          # CPU 使用率监控
          {
            systemMonitor = {
              title = "CPU";
              displayStyle = "org.kde.ksysguard.piechart";
              sensors = [
                {
                  name = "cpu/all/usage";
                  color = "61, 174, 233";  # 蓝色
                  label = "CPU %";
                }
              ];
            };
          }

          # 内存使用率监控
          {
            systemMonitor = {
              title = "Memory";
              displayStyle = "org.kde.ksysguard.piechart";
              sensors = [
                {
                  name = "memory/physical/usedPercent";
                  color = "239, 240, 241";  # 浅灰色
                  label = "Memory %";
                }
              ];
            };
          }

          # 网络速度监控 (下载)
          {
            systemMonitor = {
              title = "Network";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "network/all/download";
                  color = "118, 174, 35";  # 绿色
                  label = "↓ Download";
                }
                {
                  name = "network/all/upload";
                  color = "239, 96, 0";  # 橙色
                  label = "↑ Upload";
                }
              ];
            };
          }

          # 系统托盘
          "org.kde.plasma.systemtray"

          # 数字时钟
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
            };
          }
        ];
      }
    ];

    # 桌面小组件 - 记事贴
    desktop.widgets = [
      {
        name = "org.kde.plasma.notes";
        position = {
          horizontal = 100;
          vertical = 100;
        };
        size = {
          width = 300;
          height = 300;
        };
        config = {
          General = {
            noteId = "default";
          };
        };
      }
    ];
  };
}