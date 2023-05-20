let
  # system keys
  tsukuyomi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC7qWv7Fjim/F3koJBBzJQA22obpXlU7nnTh0ymEZjm root@tsukuyomi";
  ebisu = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBu7Uy8WIEsNQ5LsVwXzD3oaXZFTvwuUwE2hn9NbBkyC root@ebisu";
  ryuujin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKTj6ug2eor2EDMVGebzUWgfAQdXlcQZ9rjZ/EeDp9Y root@ryuujin";
  hachiman = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5sIZ/tykBmj5CgfZSvxlYL+27eBC74kp9qNw5UkPK7 root@hachiman";
  systems = [ tsukuyomi hachiman ebisu ryuujin ];

  # user keys
  tsukuyomiUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILW5ZVdVaKMVlau1wp/JGJpdpE6JUxJ07DEYHi9qOLC8 crea@tsukuyomi";
  ebisuUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon";
  raijinUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7tve12K34nhNgVYZ6VgQBRrJs10v+hClpyzpXTIb/n crea@raijin";
  ryuujinUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB0Y66xC+lCLENxktcVwGYacISi8A+KEbijg7N+w5HcF crea@ryuujin";
  users = [ tsukuyomiUser ebisuUser raijinUser ryuujinUser ];
in
{
  "restic-pass.age".publicKeys = [ tsukuyomi tsukuyomiUser ryuujinUser ];
  "nextcloud-db-pass.age".publicKeys = [ tsukuyomi tsukuyomiUser ryuujinUser ];
  "nextcloud-admin-pass.age".publicKeys = [ tsukuyomi tsukuyomiUser ryuujinUser ];
  "invidious-db-pass.age".publicKeys = [ tsukuyomi tsukuyomiUser ryuujinUser ];
  "wireguard-rnl-private.age".publicKeys = [ ryuujin ryuujinUser ebisu ebisuUser ];
  "martim_at_moniz_passwd.age".publicKeys = [ hachiman ryuujinUser ];
}
