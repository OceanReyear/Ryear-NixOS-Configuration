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

    # 本地图片文件
    face-image = {
      url = "path:/etc/nixos/picture/head-portrait/复古证件照.jpg";
      flake = false;
    };

    wallpaper = {
      url = "path:/etc/nixos/picture/background/【哲风壁纸】山峰 - 山脉 - 白雪.png";
      flake = false;
    };

    lockscreen-wallpaper = {
      url = "path:/etc/nixos/picture/background/【哲风壁纸】山峰 - 山脉 - 白雪.png";
      flake = false;
    };

    taskbar-icon = {
      url = "path:/etc/nixos/picture/taskbar-system-icon/nixos_logo_icon.ico";
      flake = false;
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
                ./hosts/reyear-nixos/home/packages.nix
                ./hosts/reyear-nixos/home/direnv.nix
                ./hosts/reyear-nixos/home/git.nix
                ./hosts/reyear-nixos/home/shell.nix
                ./hosts/reyear-nixos/home/editors.nix
                ./hosts/reyear-nixos/home/ssh.nix
                ./hosts/reyear-nixos/home/zsh.nix
                ./hosts/reyear-nixos/home/devtools.nix
                ./hosts/reyear-nixos/home/plasma.nix
              ];

              home.username = "reyear";
              home.homeDirectory = "/home/reyear";
              home.stateVersion = "25.11";
              programs.home-manager.enable = true;

              # 用户头像配置
              home.file.".face" = {
                source = inputs.face-image;
                force = true;
              };
            };
            home-manager.sharedModules = [
              inputs.plasma-manager.homeModules.plasma-manager
              {
                _module.args = {
                  faceImage = inputs.face-image;
                  wallpaper = inputs.wallpaper;
                  lockscreenWallpaper = inputs.lockscreen-wallpaper;
                  taskbarIconPath = inputs.taskbar-icon;
                };
              }
            ];
          }
        ];
      };
    };
}
