{ ... }:

{
  home.sessionVariables = {
    RUSTUP_TOOLCHAIN = "stable";
    NPM_CONFIG_REGISTRY = "https://registry.npmmirror.com";
  };

  home.file.".npmrc".text = ''
    registry=https://registry.npmmirror.com
  '';
}
