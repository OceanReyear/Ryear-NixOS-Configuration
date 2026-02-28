{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      forwardX11 = false;
      hashKnownHosts = true;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
    };
  };
}
