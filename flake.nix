{
  description = "Ryear's NixOS Configuration with Flakes";

  inputs = {
    # NixOS 官方源，锁定 25.11 分支
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # 或者使用 unstable 获取最新软件
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # NixOS 系统配置
      # 文档入口：docs/README.md
      nixosConfigurations.reyear-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/reyear-nixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.reyear = import ./hosts/reyear-nixos/home.nix;
          }
        ];
      };
    };
}
