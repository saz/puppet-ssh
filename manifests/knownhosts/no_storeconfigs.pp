class ssh::knownhosts::no_storeconfigs {
  Sshkey <| |> {
    ensure => present,
  }
}