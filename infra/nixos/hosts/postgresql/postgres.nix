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

    secrets."radarr-pg-password" = {
      owner = "postgres";
      group = "postgres";
      mode = "0400";
      restartUnits = [ "postgresql.service" ];
    };

    secrets."lidarr-pg-password" = {
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
      "radarr-main"
      "radarr-log"
      "lidarr-main"
      "lidarr-log"
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
      {
        name = "radarr";
        ensureDBOwnership = false;
        ensureClauses = {
          login = true;
        };
      }
      {
        name = "lidarr";
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
      host    radarr-main radarr all scram-sha-256
      host    radarr-log radarr all scram-sha-256
      host    lidarr-main lidarr all scram-sha-256
      host    lidarr-log lidarr all scram-sha-256
    '';
  };

  systemd.services.postgresql.postStart = lib.mkAfter ''
    PSQL="${config.services.postgresql.package}/bin/psql -U postgres"

    # 1. Ensure roles exist idempotently
    $PSQL -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'sonarr') THEN CREATE ROLE sonarr WITH LOGIN; END IF; END \$do\$;"
    $PSQL -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'prowlarr') THEN CREATE ROLE prowlarr WITH LOGIN; END IF; END \$do\$;"
    $PSQL -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'radarr') THEN CREATE ROLE radarr WITH LOGIN; END IF; END \$do\$;"
    $PSQL -c "DO \$do\$ BEGIN IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'lidarr') THEN CREATE ROLE lidarr WITH LOGIN; END IF; END \$do\$;"

    # 2. Update passwords from sops-nix secrets
    $PSQL -c "ALTER USER \"sonarr\" WITH PASSWORD '$(cat ${config.sops.secrets."sonarr-pg-password".path})';"
    $PSQL -c "ALTER USER \"prowlarr\" WITH PASSWORD '$(cat ${config.sops.secrets."prowlarr-pg-password".path})';"
    $PSQL -c "ALTER USER \"radarr\" WITH PASSWORD '$(cat ${config.sops.secrets."radarr-pg-password".path})';"
    $PSQL -c "ALTER USER \"lidarr\" WITH PASSWORD '$(cat ${config.sops.secrets."lidarr-pg-password".path})';"

    # 3. Idempotently create databases and assign owners
    for db in "sonarr-main:sonarr" "sonarr-log:sonarr" "prowlarr-main:prowlarr" "prowlarr-log:prowlarr" "radarr-main:radarr" "radarr-log:radarr" "lidarr-main:lidarr" "lidarr-log:lidarr"; do
      dbname=''${db%%:*}
      owner=''${db##*:}
      
      # Check if DB exists; if not, create it with the specified owner
      if ! $PSQL -tAc "SELECT 1 FROM pg_database WHERE datname = '$dbname'" | grep -q 1; then
        $PSQL -c "CREATE DATABASE \"$dbname\" OWNER \"$owner\";"
      else
        $PSQL -c "ALTER DATABASE \"$dbname\" OWNER TO \"$owner\";"
      fi
    done
  '';

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
