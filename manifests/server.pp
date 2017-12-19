class ssh::server(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {},
  $validate_sshd_file   = false,
  $use_augeas           = false,
  $options_absent       = [],
  $match_block          = {},
  $use_issue_net        = false
) inherits ssh::params {

  validate_hash($match_block)

  if $use_augeas {
    $merged_options = sshserver_options_to_augeas_sshd_config($options, $options_absent, { 'target' => $::ssh::params::sshd_config })
  } else {
    $merged_options = merge($ssh::params::sshd_default_options, $options)
  }

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

    Anchor['ssh::server::start']
    -> Class['ssh::server::install']
    -> Class['ssh::server::config']
    ~> Class['ssh::server::service']
    -> Class['ssh::hostkeys']
    -> Class['ssh::knownhosts']
    -> Anchor['ssh::server::end']
  } else {
    Anchor['ssh::server::start']
    -> Class['ssh::server::install']
    -> Class['ssh::server::config']
    ~> Class['ssh::server::service']
    -> Anchor['ssh::server::end']
  }

  create_resources('::ssh::server::match_block', $match_block)
}
