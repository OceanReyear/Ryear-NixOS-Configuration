{
  description = "Ryear's NixOS Configuration with Flakes and Home Manager";

  inputs = {
    # NixOS 官方稳定源
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # NixOS 不稳定源（用于获取最新软件）
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # 系统级包（使用稳定源）
      pkgs = nixpkgs.legacyPackages.${system};

      # 用户级包（可以使用不稳定源）
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

      # 特殊参数传递给所有模块
      specialArgs = {
        inherit inputs pkgs-unstable;
        # 可以添加其他自定义参数
      };
    in
    {
      # NixOS 系统配置
      nixosConfigurations.reyear-nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit specialArgs;
        modules = [
          # 主配置文件
          ./hosts/reyear-nixos/configuration.nix
          
          # 功能模块
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
