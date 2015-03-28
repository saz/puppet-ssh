class ssh (
  $server_options         = {},
  $client_options         = {},
  $manage_ssh_known_hosts = true,
  $storeconfigs_enabled   = true
) inherits ssh::params {
  class { 'ssh::server':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $server_options,
  }

  class { 'ssh::client':
    storeconfigs_enabled   => $storeconfigs_enabled,
    manage_ssh_known_hosts => $manage_ssh_known_hosts,
    options                => $client_options,
  }
}
