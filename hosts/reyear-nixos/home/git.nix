{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "reyear";
      user.email = "reyearocean@qq.com";
      init.defaultBranch = "main";
      pull.rebase = false;
      merge.conflictstyle = "diff3";
    };
  };
}
