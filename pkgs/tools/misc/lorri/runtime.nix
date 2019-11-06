# Unchanged copy of https://raw.githubusercontent.com/target/lorri/03f10395943449b1fc5026d3386ab8c94c520ee3/nix/runtime.nix

{
  # Plumbing tools:
  closureInfo
, runCommand
, writeText
, buildEnv
, # Actual dependencies to propagate:
  bash
, coreutils
}:
let
  tools = buildEnv {
    name = "lorri-runtime-tools";
    paths = [ coreutils bash ];
  };

  runtimeClosureInfo = closureInfo { rootPaths = [ tools ]; };

  closureToNix = runCommand "closure.nix" {} ''
    (
      echo '{ dep, ... }: ['
      sed -E 's/^(.*)$/    (dep \1)/' ${runtimeClosureInfo}/store-paths
      echo ']'
    ) > $out
  '';

  runtimeClosureInfoAsNix = runCommand "runtime-closure.nix" {
    runtime_closure_list = closureToNix;
    tools_build_host = tools;
  } ''
    substituteAll ${./runtime-closure.nix.template} $out
  '';
in
runtimeClosureInfoAsNix
