{
  inputs = {
    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can change the word unstable to the latest number shown here: https://nixos.org/download
    # i.e. nixos-24.11
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    hermes-agent,
    ...
  }: {
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      modules = [
        hermes-agent.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
