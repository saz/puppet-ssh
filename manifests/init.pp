class ssh (
  $server_options        = {},
  $client_options        = {},
  $users_client_options  = {},
  $version               = 'present',
  $storeconfigs_enabled  = true,
  $use_augeas            = false,
  $server_options_absent = [],
  $client_options_absent = [],
) inherits ssh::params {

  validate_hash($server_options)
  validate_hash($client_options)
  validate_hash($users_client_options)
  validate_bool($storeconfigs_enabled)
  validate_bool($use_augeas)
  validate_array($server_options_absent)

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_server_options = hiera_hash("${module_name}::server_options", undef)
  $hiera_client_options = hiera_hash("${module_name}::client_options", undef)
  $hiera_users_client_options = hiera_hash("${module_name}::users_client_options", undef)

  $fin_server_options = $hiera_server_options ? {
    undef   => $server_options,
    default => $hiera_server_options,
  }

  $fin_client_options = $hiera_client_options ? {
    undef   => $client_options,
    default => $hiera_client_options,
  }

  $fin_users_client_options = $hiera_users_client_options ? {
    undef   => $users_client_options,
    default => $hiera_users_client_options,
  }

  class { 'ssh::server':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_server_options,
    use_augeas           => $use_augeas,
    options_absent       => $server_options_absent,
  }

  class { 'ssh::client':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_client_options,
    use_augeas           => $use_augeas,
    options_absent       => $client_options_absent,
  }

  create_resources('::ssh::client::config::user', $fin_users_client_options)
}
