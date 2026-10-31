{
  description = "Pepegov NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    openspec.url = "github:Fission-AI/OpenSpec";
    calendarflow = {
      url = "path:/home/pepegov/repositoryes/Private_GitHub/CalendarFlow";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, vscode-extensions, ... }@inputs:
  let
    system = "x86_64-linux";
    dotnet = pkgs.dotnet-sdk_9;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ vscode-extensions.overlays.default ];
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations.pepegov = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs pkgs-unstable;
      };

      modules = [
        ./nixos/configuration.nix
      ];
    };

    homeConfigurations.pepegov = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;                    

      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = pkgs-unstable;
      };
      
      modules = [ ./home-manager/home.nix ];
    };

    devShells.${system} = import ./shells { inherit pkgs pkgs-unstable; };
  };
}
