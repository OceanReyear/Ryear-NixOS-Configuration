{ config, pkgs, ... }:

{
  home.username = "reyear";
  home.homeDirectory = "/home/reyear";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
