{
  description = "Pepegov NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    dotnet = pkgs.dotnet-sdk_9;

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
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
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [ ./home-manager/home.nix ];
    };

    devShells.${system}.blazor = pkgs.mkShell {
      buildInputs = [
        dotnet
        pkgs.nodejs_20
        pkgs.git
        pkgs.openssl
        pkgs.pkg-config
        pkgs.icu
        pkgs.zlib
      ];

      shellHook = ''
        export DOTNET_ROOT=${dotnet}
        export PATH=$DOTNET_ROOT/bin:$PATH

        # нужно для ASP.NET и kestrel на nix
        export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
          pkgs.openssl
          pkgs.zlib
          pkgs.icu
        ]}

        echo "Blazor dev shell ready"
        dotnet --version
      '';
    };
  };

}