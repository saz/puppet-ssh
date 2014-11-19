class ssh::client(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {},
  $warn                 = true,
  $warn_message         = $ssh::params::default_warn_message
) inherits ssh::params {
  $merged_options = merge($ssh::params::ssh_default_options, $options)

  validate_bool($warn)
  validate_string($warn_message)
  case $warn {
    false: {
      $warn_message = ''
    }
    default: {
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
