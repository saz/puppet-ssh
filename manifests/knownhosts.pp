class ssh::knownhosts {
  Sshkey <<| |>> {
    ensure => present,
  }
}
