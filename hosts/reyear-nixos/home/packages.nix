{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vim
    wget
    git
    git-lfs
    unzip
    unrar
    btop
    tree
    alacritty
    vscode
    obsidian
    firefox
    qq
    wechat-uos
    lx-music-desktop
    nix-output-monitor
    nvd
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.goland
    jetbrains.datagrip
    python3
    uv
    rustup
    go_1_24
    nodejs_22
    direnv
    nix-direnv
    ripgrep
    fd
    jq
    htop
    httpie
    sqlite
    just
    bat
    delta
    lazygit
  ];

}
