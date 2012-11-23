class ssh::hostkeys {
  $host_aliases = [ $::fqdn, $::hostname, $::ipaddress ]

  @@sshkey { "${::fqdn}_dsa":
    host_aliases => $host_aliases,
    type         => dsa,
    key          => $::sshdsakey,
  }
  @@sshkey { "${::fqdn}_rsa":
    host_aliases => $host_aliases,
    type         => rsa,
    key          => $::sshrsakey,
  }
}
