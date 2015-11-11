class ssh::hostkeys ($storeconfigs_group = undef) {
  $ipaddresses = ipaddresses()
  $host_aliases = flatten([ $::fqdn, $::hostname, $ipaddresses ])

  tag 'hostkey_all', "hostkey_${storeconfigs_group}"

  if $::sshdsakey {
    @@sshkey { "${::fqdn}_dsa":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => dsa,
      key          => $::sshdsakey,
    }
  } else {
    @@sshkey { "${::fqdn}_dsa":
      ensure       => absent,
    }
  }
  if $::sshrsakey {
    @@sshkey { "${::fqdn}_rsa":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => rsa,
      key          => $::sshrsakey,
    }
  } else {
    @@sshkey { "${::fqdn}_rsa":
      ensure       => absent,
    }
  }
  if $::sshecdsakey {
    @@sshkey { "${::fqdn}_ecdsa":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => 'ecdsa-sha2-nistp256',
      key          => $::sshecdsakey,
    }
  } else {
    @@sshkey { "${::fqdn}_ecdsa":
      ensure       => absent,
    }
  }
  if $::sshed25519key {
    @@sshkey { "${::fqdn}_ed25519":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => 'ed25519',
      key          => $::sshed25519key,
    }
  } else {
    @@sshkey { "${::fqdn}_ed25519":
      ensure       => absent,
    }
  }
}
