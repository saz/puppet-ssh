# @summary
#   This class add ssh client management
#
# @example Puppet usage
#   class { 'ssh::client':
#     ensure               => present,
#     storeconfigs_enabled => true,
#     use_augeas           => false,
#   }
#
# @param ensure
#   Ensurable param to ssh client
#
# @param storeconfigs_enabled
#   Collected host keys from servers will be written to known_hosts unless storeconfigs_enabled is false
#
# @param options
#   Dynamic hash for openssh client options
#
# @param options_absent
#   Remove options (with augeas style)
#
class ssh::client(
  String  $ensure               = present,
  Boolean $storeconfigs_enabled = true,
  Hash    $options              = {},
  Boolean $use_augeas           = false,
  Array   $options_absent       = [],
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_options = lookup("${module_name}::client::options", Optional[Hash], 'deep', {})

  $fin_options = deep_merge($hiera_options, $options)

  if $use_augeas {
    $merged_options = sshclient_options_to_augeas_ssh_config($fin_options, $options_absent, { 'target' => $ssh::params::ssh_config })
  } else {
    $merged_options = merge($fin_options, delete($ssh::params::ssh_default_options, keys($fin_options)))
  }

  include ssh::client::install
  include ssh::client::config

  anchor { 'ssh::client::start': }
  anchor { 'ssh::client::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ssh::knownhosts

    Anchor['ssh::client::start']
    -> Class['ssh::client::install']
    -> Class['ssh::client::config']
    -> Class['ssh::knownhosts']
    -> Anchor['ssh::client::end']
  } else {
    Anchor['ssh::client::start']
    -> Class['ssh::client::install']
    -> Class['ssh::client::config']
    -> Anchor['ssh::client::end']
  }
}
