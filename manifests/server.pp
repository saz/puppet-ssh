class ssh::server(
  String  $ensure               = present,
  Boolean $storeconfigs_enabled = true,
  Hash    $options              = {},
  Boolean $validate_sshd_file   = false,
  Boolean $use_augeas           = false,
  Array   $options_absent       = [],
  Hash    $match_block          = {},
  Boolean $use_issue_net        = false
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_options = lookup("${module_name}::server::options", Optional[Hash], 'deep', {})
  $hiera_match_block = lookup("${module_name}::server::match_block", Optional[Hash], 'deep', {})

  $fin_options = deep_merge($hiera_options, $options)
  $fin_match_block = deep_merge($hiera_match_block, $match_block)

  if $use_augeas {
    $merged_options = sshserver_options_to_augeas_sshd_config($fin_options, $options_absent, { 'target' => $::ssh::params::sshd_config })
  } else {
    $merged_options = deep_merge($ssh::params::sshd_default_options, $fin_options)
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

  create_resources('::ssh::server::match_block', $fin_match_block)
}
