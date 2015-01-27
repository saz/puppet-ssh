class ssh::knownhosts ($storeconfigs_group = undef) {
  Sshkey <<| tag == "hostkey_${storeconfigs_group}" |>> {
    ensure => present,
  }
}
