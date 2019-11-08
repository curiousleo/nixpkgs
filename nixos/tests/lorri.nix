import ./make-test-python.nix {
  machine = { pkgs, lib, ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    services.lorri.enable = true;
    users.users.jane = {
      isNormalUser = true;
      password = "secret";
    };
  };

  testScript = ''
    machine.wait_for_unit("sockets.target")
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("lorri.socket", "jane")
    machine.succeed("systemctl --user is-started lorri.socket", "jane")
    machine.shutdown()
  '';
}
