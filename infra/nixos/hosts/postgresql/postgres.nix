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
    ${pkgs.postgresql_17}/bin/psql -tAc "ALTER USER \"sonarr\" WITH PASSWORD '$(cat ${config.sops.secrets."sonarr-pg-password".path})'"
    ${pkgs.postgresql_17}/bin/psql -d sonarr-main -tAc 'GRANT ALL ON SCHEMA public TO "sonarr";'
    ${pkgs.postgresql_17}/bin/psql -d sonarr-log -tAc 'GRANT ALL ON SCHEMA public TO "sonarr";'

    ${pkgs.postgresql_17}/bin/psql -tAc "ALTER USER \"prowlarr\" WITH PASSWORD '$(cat ${config.sops.secrets."prowlarr-pg-password".path})'"
    ${pkgs.postgresql_17}/bin/psql -d prowlarr-main -tAc 'GRANT ALL ON SCHEMA public TO "prowlarr";'
    ${pkgs.postgresql_17}/bin/psql -d prowlarr-log -tAc 'GRANT ALL ON SCHEMA public TO "prowlarr";'
  '';

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
