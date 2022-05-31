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
# @param ssh_config
#   Path to ssh client config file
#
# @param client_package_name
#   Name of the client package
#
# @param ensure
#   Ensurable param to ssh client
#
# @param storeconfigs_enabled
#   Collected host keys from servers will be written to known_hosts unless storeconfigs_enabled is false
#
# @param options
#   SSH client options, will be deep_merged with default_options. This parameter takes precedence over default_options
#
# @param use_augeas
#   Use augeas to configure ssh client
#
# @param options_absent
#   Remove options (with augeas style)
#
# @param default_options
#   Default options to set, will be merged with options parameter
#
# @param match_block
#   Add ssh match_block (with concat)
#
class ssh::client (
  Stdlib::Absolutepath $ssh_config,
  Hash                 $default_options,
  Optional[String[1]]  $client_package_name  = undef,
  String               $ensure               = present,
  Boolean              $storeconfigs_enabled = true,
  Hash                 $options              = {},
  Boolean              $use_augeas           = false,
  Array                $options_absent       = [],
  Hash                 $match_block          = {},
) {
  if $use_augeas {
    $merged_options = sshclient_options_to_augeas_ssh_config($options, $options_absent, { 'target' => $ssh_config })
  } else {
    $merged_options = deep_merge($options, delete($default_options, keys($options)))
  }

  include ssh::client::install
  include ssh::client::config

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ssh::knownhosts

    Class['ssh::client::install']
    -> Class['ssh::client::config']
    -> Class['ssh::knownhosts']
  } else {
    Class['ssh::client::install']
    -> Class['ssh::client::config']
  }

  $match_block.each |String $k, Hash $v| {
    ssh::client::match_block { $k:
      * => $v,
    }
  }
}
