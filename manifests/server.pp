class ssh::server(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {},
  $warn                 = true,
  $warn_message         = $default_warn_message
) inherits ssh::params {
  $merged_options = merge($ssh::params::sshd_default_options, $options)

  validate_bool($warn)
  validate_string($warn_message)
  case $warn {
    false: {
      $warn_message = ''
    }
    default: {
    }
  }

  include ssh::server::install
  include ssh::server::config
  include ssh::server::service

  File[$ssh::params::sshd_config] ~> Service[$ssh::params::service_name]

  anchor { 'ssh::server::start': }
  anchor { 'ssh::server::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ssh::hostkeys
    include ssh::knownhosts

    Anchor['ssh::server::start'] ->
    Class['ssh::server::install'] ->
    Class['ssh::server::config'] ~>
    Class['ssh::server::service'] ->
    Class['ssh::hostkeys'] ->
    Class['ssh::knownhosts'] ->
    Anchor['ssh::server::end']
  } else {
    Anchor['ssh::server::start'] ->
    Class['ssh::server::install'] ->
    Class['ssh::server::config'] ~>
    Class['ssh::server::service'] ->
    Anchor['ssh::server::end']
  }
}
