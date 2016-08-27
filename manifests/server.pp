class ssh::server(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {},
  $validate_sshd_file   = false,
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_options = hiera_hash("${module_name}::server::options", undef)

  $fin_options = $hiera_options ? {
    undef   => $options,
    ''      => $options,
    default => $hiera_options,
  }

  $merged_options = merge($ssh::params::sshd_default_options, $fin_options)

  include ::ssh::server::install
  include ::ssh::server::config
  include ::ssh::server::service

  anchor { 'ssh::server::start': }
  anchor { 'ssh::server::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ::ssh::hostkeys
    include ::ssh::knownhosts

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
