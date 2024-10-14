# @summary
#   This class managed ssh server
#
# @example Puppet usage
#   class { 'ssh::server':
#     ensure               => present,
#     storeconfigs_enabled => true,
#     use_issue_net        => false,
#   }
#
# @param service_name
#   Name of the sshd service
#
# @param sshd_config
#   Path to the sshd_config file
#
# @param sshd_dir
#   Path to the sshd dir (e.g. /etc/ssh)
#
# @param sshd_binary
#   Path to the sshd binary
#
# @param sshd_config_mode
#   Mode to set on the sshd config file
#
# @param host_priv_key_group
#   Name of the group for the private host key
#
# @param default_options
#   Default options to set, will be merged with options parameter
#
# @param ensure
#   Ensurable param to ssh server
#
# @param include_dir
#   Path to sshd include directory.
#
# @param include_dir_mode
#   Mode to set on the sshd include directory.
#
# @param include_dir_purge
#   Purge the include directory if true.
#
# @param config_files
#   Hash of config files to add to the ssh include directory.
#
# @param storeconfigs_enabled
#   Host keys will be collected and distributed unless storeconfigs_enabled is false.
#
# @param options
#   Dynamic hash for openssh server option
#
# @param validate_sshd_file
#   Add sshd file validate cmd
#
# @param use_augeas
#   Use augeas for configuration (default concat)
#
# @param options_absent
#   Remove options (with augeas style)
#
# @param match_block
#   Add sshd match_block (with concat)
#
# @param use_issue_net
#   Add issue_net banner
#
# @param sshd_environments_file
#   Path to a sshd environments file (e.g. /etc/defaults/ssh on Debian)
#
# @param server_package_name
#   Name of the server package to install
#
class ssh::server (
  String[1]                      $service_name,
  Stdlib::Absolutepath           $sshd_config,
  Stdlib::Absolutepath           $sshd_dir,
  Stdlib::Absolutepath           $sshd_binary,
  Stdlib::Filemode               $sshd_config_mode,
  Integer                        $host_priv_key_group,
  Hash                           $default_options,
  Enum[present,absent,latest]    $ensure                 = present,
  Optional[Stdlib::Absolutepath] $include_dir            = undef,
  Stdlib::Filemode               $include_dir_mode       = '0700',
  Boolean                        $include_dir_purge      = true,
  Hash[String, Hash]             $config_files           = {},
  Boolean                        $storeconfigs_enabled   = true,
  Hash                           $options                = {},
  Boolean                        $validate_sshd_file     = false,
  Boolean                        $use_augeas             = false,
  Array                          $options_absent         = [],
  Hash                           $match_block            = {},
  Boolean                        $use_issue_net          = false,
  Optional[Stdlib::Absolutepath] $sshd_environments_file = undef,
  Optional[String[1]]            $server_package_name    = undef,
) {
  if $use_augeas {
    $merged_options = sshserver_options_to_augeas_sshd_config($options, $options_absent, { 'target' => $ssh::server::sshd_config })
  } else {
    $merged_options = deep_merge($default_options, $options)
  }

  contain ssh::server::install
  contain ssh::server::config
  contain ssh::server::service

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    contain ssh::hostkeys
    contain ssh::knownhosts

    Class['ssh::server::install']
    -> Class['ssh::server::config']
    ~> Class['ssh::server::service']
    -> Class['ssh::hostkeys']
    -> Class['ssh::knownhosts']
  } else {
    Class['ssh::server::install']
    -> Class['ssh::server::config']
    ~> Class['ssh::server::service']
  }

  $match_block.each |String $k, Hash $v| {
    ssh::server::match_block { $k:
      * => $v,
    }
  }
}
