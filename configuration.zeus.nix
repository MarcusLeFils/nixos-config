# configuration.zeus.nix
# =======================
# Zeus host configuration (OVH VPS). Sets hostname, enables Odyssée
# behind Caddy, and opens the standard web ports.
#
# Hardware config is in hardware-configuration.zeus.nix (generated
# on Zeus via nixos-generate-config).
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.zeus.nix
    ./modules/odyssee.nix
  ];

  # ---- Host identity ----
  networking.hostName = "zeus";

  # ---- Odyssée web app ----
  services.odyssee = {
    enable = true;
    domain = "odyssee.gasdev.fr";
    port = 3001;

    # FIXME: After first build failure, replace lib.fakeSha256 with the
    # actual SHA256 that Nix outputs in the error message.
    # repoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # ---- Nix settings ----
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://gasdev.cachix.org" ];
    trusted-public-keys = [ "gasdev.cachix.org-1:eBesrrBJpsMZ33OmvG4aKvfdyVkDa2OKCJ2o80IMJfE=" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ---- Caddy web server (handles TLS automatically) ----
  services.caddy = {
    enable = true;
    # Caddy listens on 80/443 by default — no extra config needed
  };

  # ---- Firewall: open standard web ports ----
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # ---- Basic system packages ----
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    jq
    htop
    fastfetch
  ];

  # ---- SSH ----
  services.openssh.enable = true;

  system.stateVersion = "26.11";
}