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
        engine = "auto";  # auto = uses local Chromium via CDP
        cdp_url = "http://127.0.0.1:9222";
      };
    };
  };

  users.users.root.home = lib.mkForce "/var/lib/hermes/home";
}
