class ssh::hostkeys {
  $ipaddresses = ipaddresses()
  $host_aliases = flatten([ $::fqdn, $::hostname, $ipaddresses ])

  if $::sshdsakey {
    @@sshkey { "${::fqdn}_dsa":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => dsa,
      key          => $::sshdsakey,
    }
  }
  if $::sshrsakey {
    @@sshkey { "${::fqdn}_rsa":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => rsa,
      key          => $::sshrsakey,
    }
  }
  if $::sshecdsakey {
    @@sshkey { "${::fqdn}_ecdsa":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => 'ecdsa-sha2-nistp256',
      key          => $::sshecdsakey,
    }
  }
  if $::sshed25519key {
    @@sshkey { "${::fqdn}_ed25519":
      ensure       => present,
      host_aliases => $host_aliases,
      type         => 'ed25519',
      key          => $::sshed25519key,
    }
  }
}
