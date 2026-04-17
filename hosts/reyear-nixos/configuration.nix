{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";
  networking.hostName = "reyear-nixos";
  networking.networkmanager.enable = true;

  users.users.reyear = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    # Set password locally, e.g. with `passwd reyear` after install/rebuild.
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
