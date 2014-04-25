class ssh (
  $server_options       = {},
  $client_options       = {},
  $storeconfigs_enabled = true
) inherits ssh::params {
  class { 'ssh::server':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $server_options,
  }

  class { 'ssh::client':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $client_options,
  }
}
