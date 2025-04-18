let
  keys = import ../keys.nix;
  hosts = keys.hosts;
  users = keys.users;
  allUsers = with keys.users; [ tsukuyomi ebisu ryuujin navi ];
in
{
  "restic-pass.age".publicKeys = [ hosts.tsukuyomi users.tsukuyomi users.ryuujin ];
  "nextcloud-db-pass.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "nextcloud-admin-pass.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "invidious-extra-settings.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "invidious-db-pass.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "wireguard-rnl-private.age".publicKeys = [ hosts.ryuujin hosts.navi ] ++ [ users.ryuujin users.navi ];
  "betanin-api-key.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "firefly-env.age".publicKeys = [ hosts.tsukuyomi ] ++ allUsers;
  "transmission-secrets.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "nordigen-id.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "nordigen-key.age".publicKeys = [ hosts.tsukuyomi ] ++ [ users.tsukuyomi users.ryuujin ];
  "builder-key.age".publicKeys = [ hosts.omigawa hosts.ryuujin ] ++ [ users.omigawa users.ryuujin ];
}
