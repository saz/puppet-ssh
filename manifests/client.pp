class ssh::client(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {},
  $warn                 = true,
) inherits ssh::params {
  $merged_options = merge($ssh::params::ssh_default_options, $options)

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

  include ssh::client::install
  include ssh::client::config

  anchor { 'ssh::client::start': }
  anchor { 'ssh::client::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ssh::knownhosts

    Anchor['ssh::client::start'] ->
    Class['ssh::client::install'] ->
    Class['ssh::client::config'] ->
    Class['ssh::knownhosts'] ->
    Anchor['ssh::client::end']
  } else {
    Anchor['ssh::client::start'] ->
    Class['ssh::client::install'] ->
    Class['ssh::client::config'] ->
    Anchor['ssh::client::end']
  }
}
