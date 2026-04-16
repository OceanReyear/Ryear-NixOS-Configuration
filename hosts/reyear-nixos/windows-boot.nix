{ lib, ... }:
let
  enableWindowsChainload = true;
  windowsEfiUuid = "F460-AA93";
in {
  boot.loader.grub.extraEntries = lib.optionalString enableWindowsChainload ''
    menuentry "Windows 11" {
      insmod part_gpt
      insmod fat
      insmod chain
      search --fs-uuid --set=root ${windowsEfiUuid}
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
}
