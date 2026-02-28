{ config, pkgs, ... }:

{
  imports = [
    ./home/packages.nix
    ./home/direnv.nix
    ./home/git.nix
    ./home/shell.nix
    ./home/editors.nix
    ./home/ssh.nix
  ];

  home.username = "reyear";
  home.homeDirectory = "/home/reyear";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
