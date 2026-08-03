# hermes-agent.nix
# ================
# Hermes Agent service configuration (by Nous Research).
# This is the main AI agent service that runs Marcus.
#
# Configuration overview:
# - Provider: OpenRouter, Model: deepseek/deepseek-v4-flash
# - Toolsets: CLI, web search, browser automation
# - Browser: connects to local Chromium via CDP (127.0.0.1:9222)
#   provided by the chromium-headless systemd service
# - Environment secrets loaded from /run/secrets/hermes-agent-env
# - Runs as root (container limitation) with HOME forced to /var/lib/hermes/home
#   so SSH keys, git config, gh CLI, etc. are found correctly
# - ReadWritePaths includes /nix/var/nix/profiles to allow nixos-rebuild switch
#
# Dependencies: chromium-headless.nix (browser), signal-cli-daemon.service.nix (Signal)
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
        default = "deepseek/deepseek-v4-flash-0731";
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
