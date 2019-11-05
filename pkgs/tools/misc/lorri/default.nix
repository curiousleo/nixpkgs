{ stdenv, pkgs, fetchFromGitHub, rustPlatform, CoreServices, Security
, cf-private }:

rustPlatform.buildRustPackage rec {
  pname = "lorri";
  version = "rolling-release-2019-10-30";

  src = fetchFromGitHub {
    owner = "target";
    repo = pname;
    rev = "03f10395943449b1fc5026d3386ab8c94c520ee3";
    sha256 = "0fcl79ndaziwd8d74mk1lsijz34p2inn64b4b4am3wsyk184brzq";
  };

  BUILD_REV_COUNT = src.revCount or 1;
  RUN_TIME_CLOSURE = pkgs.callPackage ./runtime.nix { };

  nativeBuildInputs = [ pkgs.nix pkgs.direnv pkgs.which ];
  buildInputs =
    stdenv.lib.optionals stdenv.isDarwin [ CoreServices Security cf-private ];

  cargoSha256 = "1daff4plh7hwclfp21hkx4fiflh9r80y2c7k2sd3zm4lmpy0jpfz";

  # Note that https://travis-ci.org/target/lorri/builds/605036891 passed.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Your project's nix-env";
    homepage = "https://github.com/target/lorri";
    license = licenses.asl20;
    maintainers = [ maintainers.Profpatsch ];
  };
}
