class ssh (
  $server_options       = {},
  $client_options       = {},
  $storeconfigs_enabled = true,
  $warn                 = true,
  $warn_message         = $default_warn_message
) inherits ssh::params {

  validate_bool($warn)
  validate_string($warn_message)
  case $warn {
    false: {
      $warn_message = ''
    }
    default: {
    }
  }

  class { 'ssh::server':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $server_options,
    warn                 => $warn,
    warn_message         => $warn_message,
  }

  class { 'ssh::client':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $client_options,
    warn                 => $warn,
    warn_message         => $warn_message,
  }
}
