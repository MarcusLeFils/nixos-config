{lib, ...}: {
  services.hermes-agent = {
    enable = true;
    environmentFiles = ["/run/secrets/hermes-agent-env"];
    addToSystemPackages = true;

    extraDependencyGroups = ["messaging"];

    createUser = false;
    user = "root";
    group = "root";

    settings = {
      model = {
        provider = "openrouter";
        model = "deepseek/deepseek-v4-flash";
      };

      # Enable web search + browser tools for research
      toolsets = ["hermes-cli" "web" "search" "browser"];

      browser = {
        engine = "auto";  # auto = uses local Chromium via CDP (agent-browser symlink)
        cdp_url = "http://127.0.0.1:9222";
      };
    };
  };

  users.users.root.home = lib.mkForce "/var/lib/hermes/home";

  # Override HOME set by the hermes-agent module (defaults to /var/lib/hermes)
  # so tools like gh, ssh, etc. find their configs in the correct home directory
  systemd.services.hermes-agent.environment.HOME = lib.mkForce "/var/lib/hermes/home";

  # Allow nixos-rebuild switch to write to the system profile
  systemd.services.hermes-agent.serviceConfig.ReadWritePaths = [
    "/nix/var/nix/profiles"
  ];
}
