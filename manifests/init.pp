class ssh (
  $server_options       = {},
  $client_options       = {},
  $version              = 'present',
  $storeconfigs_enabled = true
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_server_options = hiera_hash("${module_name}::server_options", undef)
  $hiera_client_options = hiera_hash("${module_name}::client_options", undef)

  $fin_server_options = $hiera_server_options ? {
    undef   => $server_options,
    default => $hiera_server_options,
  }

  $fin_client_options = $hiera_client_options ? {
    undef   => $server_options,
    default => $hiera_client_options,
  }

  class { 'ssh::server':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_server_options,
    ensure               => $version,
  }

  class { 'ssh::client':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_client_options,
    ensure               => $version,
  }
}
