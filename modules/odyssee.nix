# modules/odyssee.nix
# ====================
# NixOS module to deploy Odyssée (SvelteKit Node app) from
# github.com/MarcusLeFils/odyssee (private repo).
#
# Fetches the source repo, builds with pnpm (adapter-node), and runs
# behind Caddy as a reverse proxy.
#
# Usage (flake.nix):
#   nixosConfigurations.zeus = nixpkgs.lib.nixosSystem {
#     modules = [
#       ./modules/odyssee.nix
#       ./configuration.zeus.nix
#     ];
#   };
#
# Options:
#   services.odyssee.enable         — enable the service
#   services.odyssee.domain         — Caddy virtual-host domain (default: "odyssee.gasdev.fr")
#   services.odyssee.port           — internal listen port (default: 3001)
#   services.odyssee.repoUrl        — SSH git URL for the private repo
#   services.odyssee.repoRev        — pinned commit SHA (default: "main" — impure;
#                                     set a SHA for reproducibility)
#   services.odyssee.repoHash       — SHA256 of fetched source (use lib.fakeSha256,
#                                     then replace with real hash from the error msg)
#   services.odyssee.nodePackage    — nodejs derivation (default: nodejs_22)
#   services.odyssee.pnpmPackage    — pnpm derivation (default: pnpm)
#   services.odyssee.extraEnv       — extra env vars for the systemd service
#
# Requires: SSH deploy key on the build machine with access to the repo.

{ config, lib, pkgs, ... }:

let
  cfg = config.services.odyssee;

  odysseePkg = pkgs.stdenv.mkDerivation {
    name = "odyssee-web-${cfg.repoRev}";
    src = pkgs.fetchgit {
      url = cfg.repoUrl;
      rev = cfg.repoRev;
      sha256 = cfg.repoHash;
    };

    buildInputs = [ cfg.nodePackage cfg.pnpmPackage ];

    buildPhase = ''
      export HOME="$TMPDIR"
      export PUPPETEER_SKIP_DOWNLOAD=1
      export CI=1

      # pnpm install — prefer frozen lockfile, fall back to regular install
      pnpm install --frozen-lockfile 2>/dev/null || pnpm install

      # Build SvelteKit (adapter-node outputs to build/)
      pnpm build
    '';

    installPhase = ''
      # Copy the self-contained build directory to the Nix store
      cp -r build $out
    '';

    meta = with lib; {
      description = "Odyssée — SvelteKit web application";
      homepage = "https://github.com/MarcusLeFils/odyssee";
      platforms = platforms.linux;
    };
  };
in
{
  options.services.odyssee = {
    enable = lib.mkEnableOption "Odyssée web application";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "odyssee.gasdev.fr";
      description = "Domain hosting Odyssée (Caddy virtual-host)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Internal port the Node.js server listens on";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/odyssee";
      description = "Persistent writable directory for the SQLite database";
    };

    repoUrl = lib.mkOption {
      type = lib.types.str;
      default = "git@github.com:MarcusLeFils/odyssee.git";
      description = "SSH git URL of the private Odyssée repo";
    };

    repoRev = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Git revision (branch, tag, or commit SHA) to fetch";
    };

    repoHash = lib.mkOption {
      type = lib.types.str;
      default = lib.fakeSha256;
      description = ''
        SHA256 hash of the fetched source. Set to lib.fakeSha256 on first
        attempt — Nix will fail and tell you the actual hash. Copy it here.
      '';
    };

    nodePackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nodejs_22;
      description = "Node.js package to use at build and runtime";
    };

    pnpmPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pnpm;
      description = "pnpm package manager derivation";
    };

    extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables for the systemd service";
    };
  };

  config = lib.mkIf cfg.enable {
    # ---- Caddy reverse proxy ----
    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        extraConfig = ''
          reverse_proxy localhost:${toString cfg.port}
        '';
      };
    };

    # ---- Systemd service: Odyssée web ----
    systemd.services.odyssee-web = {
      description = "Odyssée web application (SvelteKit via adapter-node)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.nodePackage}/bin/node ${odysseePkg}/index.js";
        WorkingDirectory = odysseePkg;
        # Base SQLite persistante : répertoire d'état géré par systemd
        # (créé + propriété du DynamicUser), accessible en écriture.
        StateDirectory = "odyssee";
        Restart = "on-failure";
        RestartSec = 3;
        DynamicUser = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
      };

      environment = {
        PORT = toString cfg.port;
        HOST = "127.0.0.1";
        NODE_ENV = "production";
        # Pointe la base vers le répertoire persistant (le WorkingDirectory
        # en store est en lecture seule).
        DATABASE_URL = "file:${cfg.dataDir}/odyssee.db";
      } // cfg.extraEnv;
    };

    # Allow internal port through firewall (Caddy is the public face)
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.port != 80 && cfg.port != 443) [ cfg.port ];
  };
}