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

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
            home-manager.users.reyear = { config, pkgs, ... }@args: {
              imports = [
                inputs.plasma-manager.homeModules.plasma-manager
                ./hosts/reyear-nixos/home/packages.nix
                ./hosts/reyear-nixos/home/direnv.nix
                ./hosts/reyear-nixos/home/git.nix
                ./hosts/reyear-nixos/home/shell.nix
                ./hosts/reyear-nixos/home/editors.nix
                ./hosts/reyear-nixos/home/ssh.nix
                ./hosts/reyear-nixos/home/zsh.nix
                ./hosts/reyear-nixos/home/devtools.nix
                ./hosts/reyear-nixos/home/kde.nix
              ];

              home.username = "reyear";
              home.homeDirectory = "/home/reyear";
              home.stateVersion = "25.11";
              programs.home-manager.enable = true;
            };
          }
        ];
      };
    };
}
