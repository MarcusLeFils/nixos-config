# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hermes-agent.nix
    ./chromium-headless.nix
  ];

  networking.hostName = "hermes-agent"; # Define your hostname.

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = ["https://gasdev.cachix.org"];
    trusted-substituters = ["https://gasdev.cachix.org"];
    trusted-public-keys = ["gasdev.cachix.org-1:eBesrrBJpsMZ33OmvG4aKvfdyVkDa2OKCJ2o80IMJfE="];
  };

  # Automatic Nix store garbage collection (weekly)
  # Frees disk space by removing generations and store paths older than 30 days.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic store optimisation (weekly)
  # Deduplicates store paths via hard links — recovers disk space without
  # deleting anything.
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:15" ];

  # Allow running generic dynamically-linked binaries (e.g. agent-browser's
  # native npm binary) on NixOS by providing a compatible dynamic loader.
  programs.nix-ld.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # --- Productivity & dev tools ---
    helix          # Modal text editor (requested by Gaspard)
    git            # Version control for the NixOS flake + project repos
    gh             # GitHub CLI (PRs, issues, auth)
    jq             # JSON processor for API responses & scripting
    unzip          # Archive extraction

    # --- Communication & messaging ---
    himalaya       # Email CLI client (IMAP/SMTP — used by Hermes email skill)
    swaks          # Swiss Army Knife for SMTP (email testing / debugging)

    # --- Security & credentials ---
    rbw            # Rust Bitwarden client (replaced bw/bw-cli) — vaultwarden passwords
    expect         # Script interactive CLI prompts (needed by rbw pinentry setup)
    openssl        # TLS/SSL crypto tools (certificates, encryption, SMTP)

    # --- System & network utilities ---
    wget           # HTTP/S download utility
    fastfetch      # System info display (replacement for neofetch)
    inetutils      # Network utilities: ping, hostname, dnsdomainname, logger, etc.
    coreutils      # GNU core utilities — note: already pulled in by NixOS by default,
                   # included explicitly for visibility / version pinning.

    # --- Browser & automation ---
    chromium        # Web browser (used headless via CDP, port 9222 — see chromium-headless.nix)
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}
