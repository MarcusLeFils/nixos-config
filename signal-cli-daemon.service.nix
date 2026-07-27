# signal-cli-daemon.service.nix
# Declarative systemd service for signal-cli daemon
{ config, lib, pkgs, ... }:

{
  systemd.services.signal-cli-daemon = {
    description = "signal-cli daemon HTTP interface";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.signal-cli}/bin/signal-cli daemon --http 127.0.0.1:51634";
      Restart = "always";
      RestartSec = 5;
      User = "root";
      Group = "root";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}