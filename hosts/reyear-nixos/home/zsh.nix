{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$username$hostname$directory$git_branch$git_status$character";
      directory = {
        style = "cyan";
        truncation_length = 8;
        truncation_symbol = "…/";
      };
      git_branch = { style = "yellow"; };
      git_status = { style = "yellow"; };
      character = {
        success_symbol = "[➜](green)";
        error_symbol = "[➜](red)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=8";
    };
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
      }
    ];
    history = {
      size = 10000;
      save = 10000;
      share = true;
    };
    initContent = ''
      eval "$(starship init zsh)"
    '';
  };
}
