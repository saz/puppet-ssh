class ssh::client(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {}
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_options = hiera_hash("${module_name}::client::options", undef)

  $fin_options = $hiera_options ? {
    undef   => $options,
    ''      => $options,
    default => $hiera_options,
  }

  $merged_options = merge($ssh::params::ssh_default_options, $fin_options)

  include ::ssh::client::install
  include ::ssh::client::config

  anchor { 'ssh::client::start': }
  anchor { 'ssh::client::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ::ssh::knownhosts

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
