{
  description = "A dotfiles for huuhait local server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    kubenix.url = "github:hall/kubenix";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, vscode-server, ... }@inputs:
  let
    username = "huuhait";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs username system; };
      modules = [
        vscode-server.nixosModules.default
        ./nixos/configuration.nix
      ];
    };
  };
}
