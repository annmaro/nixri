let
  user1 = "age18rjgfhahe36pc9ks2g5xmxlav5p2fdkjeml48ktj3wlw3v60rv6stel0ut";
  systems = [ ];
in
{
  "private_ssh_key.age".publicKeys = [ user1 ] ++ systems;
  "codeberg-runner-token.age".publicKeys = [ user1 ] ++ systems;
  "rclone_gdrive_env.age".publicKeys = [ user1 ] ++ systems;
  "git_email.age".publicKeys = [ user1 ] ++ systems;
  "git_key_id.age".publicKeys = [ user1 ] ++ systems;
  "gemini_api_key.age".publicKeys = [ user1 ] ++ systems;
}
