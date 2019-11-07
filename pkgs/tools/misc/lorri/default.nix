{ stdenv
, pkgs
, fetchFromGitHub
, rustPlatform
  # Updater script
, runtimeShell
, writeScript
  # Apple dependencies
, CoreServices
, Security
, cf-private
}:

let
  src = fetchFromGitHub {
    owner = "target";
    repo = pname;
    # Run `eval $(nix-build -A lorri.updater)` after updating the revision!
    # See passthru.update below for what this does.
    rev = "03f10395943449b1fc5026d3386ab8c94c520ee3";
    sha256 = "0fcl79ndaziwd8d74mk1lsijz34p2inn64b4b4am3wsyk184brzq";
  };

  pname = "lorri";
  version = "rolling-release-2019-10-30";

  meta = with stdenv.lib; {
    description = "Your project's nix-env";
    homepage = "https://github.com/target/lorri";
    license = licenses.asl20;
    maintainers = [ maintainers.Profpatsch ];
  };


in
  import ./default-upstream.nix { inherit pkgs src; } // {
    updater = with builtins; writeScript "copy-runtime-nix.sh" ''
    #!${runtimeShell}
      cp ${src}/default.nix ${toString ./default-upstream.nix}
      cp ${src}/Cargo.nix ${toString ./Cargo.nix}
      cp ${src}/nix/crates-io.nix ${toString ./crates-io.nix}
      cp ${src}/nix/runtime.nix ${toString ./runtime.nix}
      cp ${src}/nix/runtime-closure.nix.template ${toString ./runtime-closure.nix.template}
    '';
  }

  #BUILD_REV_COUNT = src.revCount or 1;
  #RUN_TIME_CLOSURE = pkgs.callPackage ./runtime.nix {};

  #nativeBuildInputs = [ pkgs.nix pkgs.direnv pkgs.which ];
  #buildInputs =
    #stdenv.lib.optionals stdenv.isDarwin [ CoreServices Security cf-private ];

  #cargoSha256 = "1daff4plh7hwclfp21hkx4fiflh9r80y2c7k2sd3zm4lmpy0jpfz";

  # Note that https://travis-ci.org/target/lorri/builds/605036891 passed.
  #doCheck = false;
