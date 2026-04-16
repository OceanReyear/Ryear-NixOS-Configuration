{ pkgs, ... }:
let
  backupRemote = "git@github.com:OceanReyear/reyear-nixos.git";
in {
  # ============================================
  # 备份与灾难恢复
  # ============================================

  systemd.services.nixos-config-backup = {
    description = "Backup NixOS configuration";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      export PATH="${pkgs.git}/bin:${pkgs.openssh}/bin:${pkgs.coreutils}/bin:${pkgs.rsync}/bin:$PATH"

      BACKUP_DIR="/var/backup/nixos-config"
      SSH_DIR="/home/reyear/.ssh"
      IDENTITY_FILE="$SSH_DIR/id_ed25519"
      KNOWN_HOSTS="$SSH_DIR/known_hosts"
      DESIRED_REMOTE="${backupRemote}"

      mkdir -p "$BACKUP_DIR"
      ${pkgs.rsync}/bin/rsync -a --delete /etc/nixos/ "$BACKUP_DIR/"

      if [ -d /etc/nixos/.git ]; then
        cd /etc/nixos

        current_url="$(${pkgs.git}/bin/git -c safe.directory=/etc/nixos remote get-url origin 2>/dev/null || true)"
        case "$current_url" in
          "" )
            ${pkgs.git}/bin/git -c safe.directory=/etc/nixos remote add origin "$DESIRED_REMOTE" 2>/dev/null || true
            ;;
          "https://github.com/OceanReyear/reyear-nixos"|"https://github.com/OceanReyear/reyear-nixos.git"|"git@github.com:OceanReyear/reyear-nixos.git")
            ${pkgs.git}/bin/git -c safe.directory=/etc/nixos remote set-url origin "$DESIRED_REMOTE" || true
            ;;
          * )
            echo "Info: keep existing origin remote: $current_url"
            ;;
        esac

        ${pkgs.git}/bin/git -c safe.directory=/etc/nixos config user.name "reyear"
        ${pkgs.git}/bin/git -c safe.directory=/etc/nixos config user.email "reyearocean@qq.com"
        ${pkgs.git}/bin/git -c safe.directory=/etc/nixos add -A
        if ! ${pkgs.git}/bin/git -c safe.directory=/etc/nixos diff --cached --quiet; then
          ${pkgs.git}/bin/git -c safe.directory=/etc/nixos -c user.name="reyear" -c user.email="reyearocean@qq.com" \
            commit -m "nixos-backup: $(date '+%Y-%m-%d %H:%M:%S')"

          if [ ! -f "$IDENTITY_FILE" ]; then
            echo "Info: SSH key $IDENTITY_FILE not found, skip git push."
            exit 0
          fi

          export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i $IDENTITY_FILE -o UserKnownHostsFile=$KNOWN_HOSTS -o StrictHostKeyChecking=accept-new"
          ${pkgs.git}/bin/git -c safe.directory=/etc/nixos push origin main 2>&1 || \
            echo "Warning: Git push failed; backup commit kept locally."
        fi
      fi
    '';
  };

  systemd.timers.nixos-config-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "10min";
    };
  };
}
