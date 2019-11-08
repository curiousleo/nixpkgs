{ config, lib, pkgs, ... }:

let
  cfg = config.services.lorri;
  socketUnit = "lorri";
  socketPath = "lorri/daemon.socket";
in {
  options = {
    services.lorri = {
      enable = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          This option enables a systemd socket unit that listens on the
          well-known address used by lorri, a nix-shell replacement for project
          development. When a lorri client connects to the socket, systemd
          starts the lorri daemon as a service.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.sockets.${socketUnit} = {
      description = "Socket for Lorri Daemon";
      wantedBy = [ "sockets.target" ];
      unitConfig = {
        ConditionUser = "!@system";
      };
      socketConfig = {
        ListenStream = "%t/${socketPath}";
        RuntimeDirectory = "lorri";
      };
    };

    systemd.user.services.lorri = {
      description = "Lorri Daemon";
      requires = [ "${socketUnit}.socket" ];
      after = [ "${socketUnit}.socket" ];
      path = with pkgs; [ config.nix.package gnutar gzip ];
      environment = {
        RUST_LOG = "warn";
      };
      unitConfig = {
        ConditionUser = "!@system";
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
