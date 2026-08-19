{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;

    ensureDatabases = [
      "sonarr-main"
      "sonarr-log"
    ];

    ensureUsers = [
      {
        name = "sonarr";
        ensureDBOwnership = false;
        ensureClauses = {
          login = true;
          password = "SCRAM-SHA-256$4096:VbRn9He+emErOwv7OdEFXg==$9iqS8theS9dQJYtwSLjdKKqphi/E0FyRB0854eFr3w4=:o1yGBdTDFn2S5HZG3Bwu8wlMj950W22wWSPeWMt2AJM=";
        };
      }
    ];

    authentication = lib.mkOverride 10 ''
      local   all all trust
      host    all all 127.0.0.1/32 trust
      host    all all ::1/128 trust
      host    sonarr-main sonarr all scram-sha-256
      host    sonarr-log sonarr all scram-sha-256
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
