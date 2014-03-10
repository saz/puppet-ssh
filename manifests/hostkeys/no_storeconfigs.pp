class ssh::hostkeys::no_storeconfigs {
  @sshkey { "${::fqdn}_dsa":
    host_aliases => $host_aliases,
    type         => dsa,
    key          => $::sshdsakey,
  }
  @sshkey { "${::fqdn}_rsa":
    host_aliases => $host_aliases,
    type         => rsa,
    key          => $::sshrsakey,
  }
  if $::sshecdsakey {
    @sshkey { "${::fqdn}_ecdsa":
      host_aliases => $host_aliases,
      type         => 'ecdsa-sha2-nistp256',
      key          => $::sshecdsakey,
    }
  }
}