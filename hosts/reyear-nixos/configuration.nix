{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./hibernate.nix
    ./windows-boot.nix
    ./lenovo.nix
  ];

  networking.hostName = "reyear-nixos";
}
