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
    ];

    ensureUsers = [
      {
        name = "sonarr";
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
    '';
  };

  # ensureClauses no longer supports a `password` clause since nixos-25.11,
  # so set the SCRAM-SHA-256 hash for sonarr via postStart on every restart.
  # The hash is derived from the sops-managed plaintext password so the
  # secret never has to live in this file or anywhere in the repo in clear.
  systemd.services.postgresql.postStart = lib.mkAfter ''
    ${pkgs.postgresql_17}/bin/psql -tAc \
      "ALTER USER \"sonarr\" WITH PASSWORD '$(cat ${config.sops.secrets."sonarr-pg-password".path})'"
    # PostgreSQL 15+ restricts CREATE on the public schema to its owner, which is
    # `postgres` for DBs created by ensureDatabases. Grant schema access so Sonarr
    # (non-owner) can run its migrations.
    ${pkgs.postgresql_17}/bin/psql -d sonarr-main -tAc 'GRANT ALL ON SCHEMA public TO "sonarr";'
    ${pkgs.postgresql_17}/bin/psql -d sonarr-log -tAc 'GRANT ALL ON SCHEMA public TO "sonarr";'
  '';

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
