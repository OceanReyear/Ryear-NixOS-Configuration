{
  description = "Ryear's NixOS Configuration with Flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      specialArgs = { inherit inputs pkgs-unstable; };
    in
    {
      nixosConfigurations.reyear-nixos = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          # 使用简单的相对路径（已验证正确）
          ./hosts/reyear-nixos/configuration.nix
          ./modules/btrfs.nix
          ./modules/boot.nix
          ./modules/desktop.nix
          ./modules/network.nix
          ./modules/nix.nix
          ./modules/users.nix
          ./modules/security.nix
          ./modules/snapper.nix
          ./modules/fonts.nix
          
          # Home Manager 集成
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.reyear = import ./home/reyear.nix;
            };
          }
        ];
      };
    };
}
