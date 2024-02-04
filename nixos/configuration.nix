{ config, pkgs, username, ... }: {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./locale.nix
  ];

  # nix
  documentation.nixos.enable = false; # .desktop
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  # virtualisation
  programs.virt-manager.enable = true;
  virtualisation = {
    podman.enable = true;
    libvirtd.enable = true;
  };

  # dconf
  programs.dconf.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    ansible
    vault
    kubectl
    consul
    terraform
    helm
  ];

  # logind
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=ignore
  '';

  # user
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = username;
    extraGroups = [
      "nixosvmtest"
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
  };

  virtualisation.docker.enable = true;

  users.extraGroups.docker.members = [
    "huuhait"
  ];

  # network
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;

    firewall = {
      enable = false;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      AllowUsers = [
        username
      ];
    };
  };

  # bootloader
  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
    loader = {
      timeout = 5;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
      };
    };
  };

  system.stateVersion = "23.11";
}
