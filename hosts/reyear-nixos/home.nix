{ config, pkgs, faceImage, ... }:

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
    ./home/plasma.nix
  ];

  home.username = "reyear";
  home.homeDirectory = "/home/reyear";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    kdePackages.plasma-workspace
    kdePackages.plasma-nm
  ];

  # 用户头像配置
  home.file.".face" = {
    source = faceImage;
    force = true;
  };
}
