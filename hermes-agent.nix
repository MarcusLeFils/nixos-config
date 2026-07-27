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
      platforms.email.require_authenticated_sender = false;
    };
  };

  users.users.root.home = lib.mkForce "/var/lib/hermes/home";
}
