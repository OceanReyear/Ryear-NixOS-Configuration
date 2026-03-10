{ config, pkgs, ... }:

{
  imports = [
    ./home/packages.nix
    ./home/direnv.nix
    ./home/git.nix
    ./home/shell.nix
    ./home/editors.nix
    ./home/ssh.nix
    ./home/zsh.nix
    ./home/devtools.nix
  ];

  home.username = "reyear";
  home.homeDirectory = "/home/reyear";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # KDE Plasma 配置
  # 使用xdg.configFile手动管理KDE配置
  xdg.configFile = {
    # KWin 窗口特效配置
    "kwinrc" = {
      force = true;
      text = ''
        [Windows]
        BorderSnapZone=10
        CenterSnapZone=0
        SnapOnlyWhenClose=false
        ActiveMouseScreen=true

        [Effect-wobblywindows]
        Wobblyness=4

        [Effect-magiclamp]
        AnimationDuration=400

        [Effect-desktopgrid]
        BorderActivate=9

        [Effect-presentwindows]
        BorderActivateAll=9
      '';
    };

    # Plasma 面板配置
    "plasmashellrc" = {
      force = true;
      text = ''
        [PlasmaViews][Panel 2]
        floating=1

        [PlasmaViews][Panel 2][Defaults]
        thickness=44
      '';
    };
  };

  # 添加系统监视器小组件到包列表
  home.packages = with pkgs; [
    kdePackages.plasma-systemmonitor
    kdePackages.plasma-workspace
    kdePackages.ksystemstats
    kdePackages.plasma-nm
  ];
}
