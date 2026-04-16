{ pkgs, ... }:
let
  # Host-specific resume offset for /swap/swapfile.
  resumeOffset = "14427392";
in {
  boot.resumeDevice = "/dev/mapper/cryptroot";
  boot.kernelParams = [ "resume_offset=${resumeOffset}" ];

  system.activationScripts.resume-offset-check = {
    deps = [ "specialfs" ];
    text = ''
      if [ -f /swap/swapfile ]; then
        expected="${resumeOffset}"
        actual="$(${pkgs.btrfs-progs}/bin/btrfs inspect-internal map-swapfile -r /swap/swapfile 2>/dev/null || true)"
        if [ -n "$actual" ] && [ "$actual" != "$expected" ]; then
          echo "Warning: resume_offset mismatch. Expected $expected, got $actual." >&2
          echo "Run: btrfs inspect-internal map-swapfile -r /swap/swapfile and update hosts/reyear-nixos/hibernate.nix." >&2
        fi
      fi
    '';
  };
}
