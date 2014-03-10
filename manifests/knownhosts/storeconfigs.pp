class ssh::knownhosts::storeconfigs {
  Sshkey <<| |>> {
    ensure => present,
  }
}