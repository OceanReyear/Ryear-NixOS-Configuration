{ ... }:
{
  # 通过 systemd 服务启用 Lenovo conservation mode
  systemd.services.lenovo-conservation-mode = {
    description = "Enable Lenovo battery conservation mode";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ -f /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode ]; then
        echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
        echo "Lenovo conservation mode enabled"
      fi
    '';
  };
}
