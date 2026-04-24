{
  description = "Pepegov NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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
        ./configuration.nix
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
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

    # devShells.${system}.default = pkgs.mkShell {
    #   packages = [
    #     (with pkgs.dotnetCorePackages; combinePackages [
    #       sdk_8_0
    #       sdk_9_0
    #       sdk_10_0
    #     ])
    #   ];
    #   DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_9_0}";
    # };

    # devShells.${system}.default = pkgs.mkShell {
    #   packages = with pkgs; [
    #     (dotnetCorePackages.combinePackages [
    #       dotnetCorePackages.sdk_9_0
    #     ])
    #   ];

    #   shellHook = ''
    #     export DOTNET_ROOT="${pkgs.dotnetCorePackages.combinePackages [ pkgs.dotnetCorePackages.sdk_9_0 ]}/share/dotnet"
    #     export DOTNET_MULTILEVEL_LOOKUP=0
    #     echo "DOTNET_ROOT настроен для .NET 9"
    #   '';
    # };
  };

}