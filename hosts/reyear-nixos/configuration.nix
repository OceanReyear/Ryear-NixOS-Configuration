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
    # Set password from a root shell after first boot (or installer rescue), e.g. `passwd reyear`.
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
