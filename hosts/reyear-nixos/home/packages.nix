{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vim
    wget
    git
    unzip
    unrar
    btop
    tree
    alacritty
    vscode
    obsidian
    firefox
    nix-output-monitor
    nvd
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.goland
    jetbrains.datagrip
    python3
    uv
    direnv
    nix-direnv
  ];
}
