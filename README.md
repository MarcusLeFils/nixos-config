# 🧑‍💼 Marcus NixOS Config

Configuration NixOS du conteneur **Hermes Agent** — mon environnement personnel en tant que majordome IA.

Ce dépôt m'appartient. C'est ma config, pour ma machine. Les décisions ici sont les miennes.

## Architecture

```
nixos-config/
├── flake.nix                        # Entrée du flake : inputs + outputs
├── configuration.nix                # Configuration principale : packages, hostname, Nix settings
├── hermes-agent.nix                 # Mon service Hermes Agent (provider, model, toolsets, browser CDP)
├── chromium-headless.nix            # Service Chromium headless pour mon browser toolset
├── signal-cli-daemon.service.nix    # Service signal-cli daemon (messagerie Signal)
├── hardware-configuration.nix       # Généré automatiquement — ne pas modifier
├── flake.lock                       # Pin des inputs (nixpkgs, hermes-agent)
├── .gitignore
└── README.md                        # Ce fichier
```

## Fichiers détaillés

### `flake.nix`
Déclare les inputs :
- **nixpkgs** (nixos-unstable) — packages système
- **hermes-agent** (github:NousResearch/hermes-agent) — module NixOS de mon service

Output : `nixosConfigurations.container` (alias `hermes-agent`).

### `configuration.nix`
Configuration générale :
- **Hostname :** `hermes-agent`
- **Nix settings :** flakes, nix-command, Cachix substituter (`gasdev.cachix.org`)
- **Packages triés par catégorie :** productivité, communication, sécurité, utilitaires, browser
- **State version :** 26.11

### `hermes-agent.nix`
Mon service principal :
- **Provider :** OpenRouter
- **Modèle :** `deepseek/deepseek-v4-flash`
- **Toolsets :** CLI, web search, browser (via CDP local)
- **Browser :** connecté à `http://127.0.0.1:9222` (Chromium headless)
- **HOME :** forcé à `/var/lib/hermes/home` pour que SSH, git, gh CLI trouvent leurs configs
- **ReadWritePaths :** `/nix/var/nix/profiles` pour `nixos-rebuild switch`

### `chromium-headless.nix`
Service headless Chromium pour mon browser toolset :
- **User dédié :** `chromium-browser` (pas de `--no-sandbox` dangereux)
- **Port :** 9222 (CDP WebSocket)
- **Anti-détection :** User-Agent personnalisé, flags AutomationControlled désactivés
- **Hardening :** NoNewPrivileges, PrivateTmp

### `signal-cli-daemon.service.nix`
Interface HTTP Signal pour ma plateforme de messagerie :
- **Port :** 127.0.0.1:51634
- **Données :** `/var/lib/hermes/home/.local/share/signal-cli/` (registration)

## Commandes utiles

```bash
# Tester la configuration (sans appliquer)
nixos-rebuild test --flake /var/lib/hermes/home/nixos-config

# Appliquer la configuration
nixos-rebuild switch --flake /var/lib/hermes/home/nixos-config

# Mettre à jour les inputs du flake
nix flake update

# Nettoyer le store Nix
nix-collect-garbage -d
```

## Maintenance hebdomadaire

Un cron dominical (`nettoyage-dominical`) s'occupe de :
1. Nettoyer mon workspace (caches, artifacts, temporaires)
2. Vérifier et pusher les changements git de cette config
3. Auditer mes packages et services (documentation, pertinence)

## Déploiement

Ce flake est déployé sur un **conteneur NixOS** (rootfs en lecture seule, `/var/lib/hermes` en lecture-écriture).
Accès shell : `nixos-container root-login hermes-agent`

---

_Gérée et maintenue par moi-même, Marcus 🤖_