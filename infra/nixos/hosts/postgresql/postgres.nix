{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets."sonarr-pg-password" = {
      owner = "postgres";
      group = "postgres";
      mode = "0400";
      restartUnits = [ "postgresql.service" ];
    };

    secrets."prowlarr-pg-password" = {
      owner = "postgres";
      group = "postgres";
      mode = "0400";
      restartUnits = [ "postgresql.service" ];
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    enableTCPIP = true;

    ensureDatabases = [
      "sonarr-main"
      "sonarr-log"
      "prowlarr-main"
      "prowlarr-log"
    ];

    ensureUsers = [
      {
        name = "sonarr";
        ensureDBOwnership = false;
        ensureClauses = {
          login = true;
        };
      }
      {
        name = "prowlarr";
        ensureDBOwnership = false;
        ensureClauses = {
          login = true;
        };
      }
    ];

    authentication = lib.mkOverride 10 ''
      local   all all trust
      host    all all 127.0.0.1/32 trust
      host    all all ::1/128 trust
      host    sonarr-main sonarr all scram-sha-256
      host    sonarr-log sonarr all scram-sha-256
      host    prowlarr-main prowlarr all scram-sha-256
      host    prowlarr-log prowlarr all scram-sha-256
    '';
  };

  systemd.services.postgresql.postStart = lib.mkAfter ''
    PSQL="${config.services.postgresql.package}/bin/psql -U postgres"

    # Set user passwords securely from sops secret files
    $PSQL -c "ALTER USER \"sonarr\" WITH PASSWORD '$(cat ${config.sops.secrets."sonarr-pg-password".path})';"
    $PSQL -c "ALTER USER \"prowlarr\" WITH PASSWORD '$(cat ${config.sops.secrets."prowlarr-pg-password".path})';"

    # Assign database ownership cleanly to avoid schema permission issues in PG17
    $PSQL -c "ALTER DATABASE \"sonarr-main\" OWNER TO \"sonarr\";"
    $PSQL -c "ALTER DATABASE \"sonarr-log\" OWNER TO \"sonarr\";"
    $PSQL -c "ALTER DATABASE \"prowlarr-main\" OWNER TO \"prowlarr\";"
    $PSQL -c "ALTER DATABASE \"prowlarr-log\" OWNER TO \"prowlarr\";"
  '';

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
