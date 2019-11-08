{ config, lib, pkgs, ... }:

let
  cfg = config.services.lorri;
  socketUnit = "lorri";
  socketPath = "lorri/daemon.socket";
in with lib; {
  options = {
    services.lorri = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          This option enables a systemd socket unit that listens on the
          well-known address used by lorri, a nix-shell replacement for project
          development. When a lorri client connects to the socket, systemd
          starts the lorri daemon as a service.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.sockets.${socketUnit} = {
      description = "Socket for Lorri Daemon";
      enable = true;
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = "%t/${socketPath}";
        RuntimeDirectory = "lorri";
      };
    };

    systemd.user.services.lorri = {
      description = "Lorri Daemon";
      requires = [ "${socketUnit}.socket" ];
      after = [ "${socketUnit}.socket" ];
      path = with pkgs; [ nix gnutar gzip ];
      environment = {
        # lorri is not yet stable.
        RUST_BACKTRACE = "full";
        RUST_LOG = "warn";
      };
      unitConfig = {
        ConditionUser = "!@system";
        RefuseManualStart = true;
      };
      serviceConfig = {
        ExecStart = "${pkgs.lorri}/bin/lorri daemon";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        Restart = "on-failure";
      };
    };
  };
}
