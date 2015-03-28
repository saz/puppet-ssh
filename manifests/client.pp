class ssh::client(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $manage_ssh_known_hosts,
  $options              = {}
) inherits ssh::params {
  $merged_options = merge($ssh::params::ssh_default_options, $options)

  include ssh::client::install
  class { 'ssh::client::config':
    manage_ssh_known_hosts => $manage_ssh_known_hosts,
  }

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
