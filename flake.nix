{
  description = "reyear-nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nix-openclaw.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.reyear-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/nixos/common.nix
          ./hosts/reyear-nixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs pkgs; };
            home-manager.users.reyear = { config, pkgs, inputs, ... }: {
              imports = [
                inputs.plasma-manager.homeModules.plasma-manager
                ./hosts/reyear-nixos/home.nix
              ];
            };
          }
        ];
      };

      # Home Manager standalone configuration (required for nix-openclaw)
      homeConfigurations."reyear" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.nix-openclaw.homeManagerModules.openclaw
          ./hosts/reyear-nixos/home.nix
          ./hosts/reyear-nixos/home/openclaw.nix  # OpenClaw config
        ];
      };
    };
}
