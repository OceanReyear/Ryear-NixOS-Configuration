{ ... }:

{
  programs.bash = {
    enable = true;
  };

  home.sessionPath = [ "/etc/nixos/scripts" ];
}
