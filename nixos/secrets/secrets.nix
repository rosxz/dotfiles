let
  # system keys
  tsukuyomi = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC7qWv7Fjim/F3koJBBzJQA22obpXlU7nnTh0ymEZjm root@tsukuyomi" ];
  systems = [ tsukuyomi ];

  # user keys
  tsukuyomiUser = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILW5ZVdVaKMVlau1wp/JGJpdpE6JUxJ07DEYHi9qOLC8 crea@tsukuyomi" ];
  ebisuUser = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJcUMSSFZQheROdhFVmIUwBTbAVBv9YUm/Ib3ED3O0gv crea@pasokon" ];
  users = [ tsukuyomiUser ebisuUser ];
in
{
  "restic-pass.age".publicKey = [ tsukuyomi tsukuyomiUser ebisuUser ];
}
