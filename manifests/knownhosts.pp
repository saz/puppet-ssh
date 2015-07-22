class ssh::knownhosts(
  $collect_enabled = true
) {
  if ($collect_enabled) {
    Sshkey <<| |>>
  }
}
