{ config, lib, pkgs, ... }:

let
  chromiumUser = "chromium-browser";
  chromiumDataDir = "/var/lib/${chromiumUser}";
in
{
  users.users.${chromiumUser} = {
    isSystemUser = true;
    group = chromiumUser;
    home = chromiumDataDir;
    createHome = true;
  };

  users.groups.${chromiumUser} = {};

  systemd.services.chromium-headless = {
    description = "Headless Chromium for Hermes browser toolset (CDP)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = chromiumUser;
      Group = chromiumUser;
      ExecStart = "${pkgs.chromium}/bin/chromium \
        --headless \
        --remote-debugging-port=9222 \
        --user-data-dir=${chromiumDataDir} \
        --no-first-run \
        --no-default-browser-check \
        --disable-gpu \
        --disable-software-rasterizer";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStartSec = 30;
      # Hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
    };
  };
}