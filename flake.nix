{
  description = "Marcus NixOS Config — Hermes Agent container. Mon environnement personnel : packages, services (Hermes, Chromium CDP, Signal CLI), et configuration système.";

  inputs = {
    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can change the word unstable to the latest number shown here: https://nixos.org/download
    # i.e. nixos-24.11
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    # Odyssée : package + module NixOS exposés par le repo (flake input).
    # URL SSH : utilise la clé de déploiement (repo privé), pas le token HTTPS.
    odyssee = {
      url = "git+ssh://git@github.com/MarcusLeFils/odyssee";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    hermes-agent,
    odyssee,
    ...
  }: {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      modules = [
        hermes-agent.nixosModules.default
        ./configuration.nix
      ];
    };
    nixosConfigurations.hermes-agent = self.nixosConfigurations.container;

    # Zeus: OVH VPS hosting Odyssée (SvelteKit web app) behind Caddy.
    nixosConfigurations.zeus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.zeus.nix
        ./configuration.zeus.nix
        odyssee.nixosModules.default
      ];
    };
  };
}
