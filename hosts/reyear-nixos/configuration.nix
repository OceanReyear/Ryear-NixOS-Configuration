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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "mirrors.tuna.tsinghua.edu.cn-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
