# chromium-headless.nix
# =====================
# Headless Chromium providing a CDP (Chrome DevTools Protocol) endpoint
# for Hermes Agent's browser toolset (browser_navigate, browser_click, etc.).
#
# Key design decisions:
# - Runs as a dedicated "chromium-browser" system user (not root!)
#   => avoids dangerous --no-sandbox flag
# - Listens on 127.0.0.1:9222 (CDP WebSocket endpoint)
# - Anti-detection flags: --disable-blink-features=AutomationControlled,
#   custom User-Agent, --disable-features=ChromeWhatsNewUI, etc.
# - Light hardening: NoNewPrivileges, PrivateTmp
# - Restart on failure with 5s delay
#
# Added: July 2026 — replaced a failed attempt to use Hermes' built-in
# Playwright-based browser (which required --no-sandbox in the container).
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
      ExecStart = ''
        ${pkgs.chromium}/bin/chromium --headless=new --remote-debugging-port=9222 --user-data-dir=${chromiumDataDir} --no-first-run --no-default-browser-check --disable-gpu --disable-crashpad-forwarding --disable-blink-features=AutomationControlled --disable-features=ChromeWhatsNewUI,ChromeInProductHelp,ChromeWhatsNewService,TranslateUI --window-size=1920,1080 --start-maximized --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36"
      '';
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStartSec = 30;
      # Light hardening — Chromium needs /dev/urandom, shared libs, fonts
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };
}