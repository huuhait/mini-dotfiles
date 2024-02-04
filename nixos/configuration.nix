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

    containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs;[
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in {
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
        # Optionally set private registry credentials here instead of using /etc/rancher/k3s/registries.yaml
        # plugins."io.containerd.grpc.v1.cri".registry.configs."registry.example.com".auth = {
        #  username = "";
        #  password = "";
        # };
      };
  };
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
    kubernetes-helm
    k3s
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

  services.vscode-server = {
    enable = true;
  };

  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    extraFlags = toString [
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
      "--disable=traefik"
    ];
  };

  systemd.services.k3s.path = [ pkgs.ipset ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /export/k8s         *(rw,sync,no_subtree_check,no_root_squash)
    '';
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
