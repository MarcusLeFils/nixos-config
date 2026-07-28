# signal-cli-daemon.service.nix
# ==============================
# HTTP interface for Signal messaging.
# signal-cli runs as a systemd daemon listening on 127.0.0.1:51634.
# Hermes Agent connects to this daemon for Signal platform integration
# (sending/receiving messages via the Signal CLI tool).
#
# History: migrated from manual nix-env install to declarative NixOS service.
# The data directory (~/.local/share/signal-cli) contains the Signal registration
# and was preserved during migration.
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