class ssh (
  $server_options       = {},
  $client_options       = {},
  $storeconfigs_enabled = true,
  $warn                 = true,
) inherits ssh::params {
  case $warn {
    'true', true, yes, on: {
      $warnmsg = $default_warn_message
    }
    'false', false, no, off: {
      $warnmsg = ''
    }
    default: {
      $warnmsg = $warn
    }
  }

  class { 'ssh::server':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $server_options,
    warn                 => $warnmsg,
  }

  class { 'ssh::client':
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $client_options,
    warn                 => $warnmsg,
  }
}
