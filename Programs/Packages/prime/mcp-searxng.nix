   { pkgs ? import <nixpkgs> {} }:

   pkgs.buildNpmPackage {
     pname = "mcp-searxng";
     version = "1.15.0";

     src = pkgs.fetchFromGitHub {
       owner = "ihor-sokoliuk";
       repo = "mcp-searxng";
       rev = "v1.15.0"; # Or use a specific commit hash
       hash =
        #  pkgs.lib.fakeHash
        "sha256-vNh96VKUD+hrwVhHvVAk88IKunfsY2gQ8WWmgRaywqY="

       ;
     };

     # The hash of the npm dependencies.
     # Run nix-build to get the correct hash from the error message.
     npmDepsHash = "sha256-LYVlgiEIZ2MoLifrASjQxeZjqKfKccKZKMFFfSR6kUs=";

     # Build requirements
     nativeBuildInputs = [ pkgs.nodejs ];

     meta = {
       description = "MCP server for SearXNG integration";
       homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
       license = pkgs.lib.licenses.mit;
       mainProgram = "mcp-searxng";
     };
   }