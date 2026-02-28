{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      ms-python.python
      rust-lang.rust-analyzer
      golang.go
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
    ];
    userSettings = {
      "editor.formatOnSave" = true;
      "editor.tabSize" = 2;
      "files.trimTrailingWhitespace" = true;
      "git.autofetch" = true;
      "terminal.integrated.defaultProfile.linux" = "zsh";
    };
  };
}
