{
  description = "A dotfiles for huuhait local server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    kubenix.url = "github:hall/kubenix";
  };

  outputs = { self, nixpkgs, kubenix, ... }@inputs:
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
        kubenix
        ./nixos/configuration.nix
      ];
    };

    homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs username; };
      modules = [ ./home-manager/home.nix ];
    };
  };
}
