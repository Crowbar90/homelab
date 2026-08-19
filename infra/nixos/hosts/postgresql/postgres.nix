{
  config,
  pkgs,
  lib,
  ...
}:

let
  sonarrPasswordHash = "SCRAM-SHA-256$4096:346BtNfVTUzxhULOG94xPg==$uoeny9dMx6f/C0Q0iHmdT13pVsuNkiSrhaOkI00x2Gs=:ZM4VddkFPkOHlZG3rinUeGYdsngBWk6QKpJBLaeKYHY=";
in
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
  systemd.services.postgresql.postStart = lib.mkAfter ''
    ${pkgs.postgresql_17}/bin/psql -tAc "ALTER USER \"sonarr\" WITH PASSWORD '${sonarrPasswordHash}'"
  '';

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
