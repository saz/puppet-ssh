# @summary
#   This class manages ssh client and server
#
# @example Puppet usage
#   class { 'ssh':
#     storeconfigs_enabled         => false,
#     server_options               => {
#       'Match User www-data'      => {
#         'ChrootDirectory'        => '%h',
#         'ForceCommand'           => 'internal-sftp',
#         'PasswordAuthentication' => 'yes',
#         'AllowTcpForwarding'     => 'no',
#         'X11Forwarding'          => 'no',
#       },
#       'Port'                     => [22, 2222, 2288],
#     },
#     client_options               => {
#       'Host *.amazonaws.com'     => {
#         'User'                   => 'ec2-user',
#       },
#     },
#     users_client_options         => {
#       'bob'                      => {
#         options                  => {
#           'Host *.alice.fr'      => {
#             'User'               => 'alice',
#           },
#         },
#       },
#     },
#    'server_instances' => {
#      'sftp_server_init' => {
#        'ensure' => 'present',
#        'options' => {
#          'sshd_config' => {
#            'Port' => 8022,
#            'Protocol' => 2,
#            'AddressFamily' => 'any',
#            'HostKey' => '/etc/ssh/ssh_host_rsa_key',
#            'SyslogFacility' => 'AUTH',
#            'LogLevel' => 'INFO',
#            'PermitRootLogin' => 'no',
#          },
#          'sshd_service_options' => '',
#          'match_blocks' => {
#            '*,!ssh_exempt_ldap_authkey,!sshlokey' => {
#              'type' => 'group',
#              'options' => {
#                'AuthorizedKeysCommand' => '/usr/local/bin/getauthkey',
#                'AuthorizedKeysCommandUser' => 'nobody',
#                'AuthorizedKeysFile' => '/dev/null',
#              },
#            },
#          },
#        },
#      },
#    },
#  }
#
# @example hiera usage
#   ssh::storeconfigs_enabled: true
#
#   ssh::server_options:
#       Protocol: '2'
#       ListenAddress:
#           - '127.0.0.0'
#           - '%{::hostname}'
#       PasswordAuthentication: 'yes'
#       SyslogFacility: 'AUTHPRIV'
#       UsePAM: 'yes'
#       X11Forwarding: 'yes'
#
#   ssh::server::match_block:
#     filetransfer:
#       type: group
#       options:
#         ChrootDirectory: /home/sftp
#         ForceCommand: internal-sftp
#
#   ssh::client_options:
#       'Host *':
#           SendEnv: 'LANG LC_*'
#           ForwardX11Trusted: 'yes'
#           ServerAliveInterval: '10'
#
#   ssh::users_client_options:
#       'bob':
#           'options':
#               'Host *.alice.fr':
#                   'User': 'alice'
#                   'PasswordAuthentication': 'no'
#    ssh::server::server_instances:
#       sftp_server_init:
#         ensure: present
#         options:
#           sshd_config:
#            Port: 8022
#            Protocol: 2
#            AddressFamily: 'any'
#            HostKey: '/etc/ssh/ssh_host_rsa_key'
#            SyslogFacility: 'AUTH'
#            LogLevel: INFO
#            PermitRootLogin: 'no'
#         sshd_service_options: ''
#         match_blocks:
#           '*,!ssh_exempt_ldap_authkey,!sshlokey':
#              type: group
#              options:
#                AuthorizedKeysCommand: '/usr/local/bin/getauthkey'
#                AuthorizedKeysCommandUser: 'nobody'
#                AuthorizedKeysFile: '/dev/null'
#
#
# @server_instances
#   Configure SSH instances
#
# @param server_options
#   Add dynamic options for ssh server config
#
# @param server_match_block
#   Add match block for ssh server config
#
# @param client_options
#   Add dynamic options for ssh client config
#
# @param users_client_options
#   Add users options for ssh client config
#
# @param version
#   Define package version (package ressource)
#
# @param storeconfigs_enabled
#   Default value for storeconfigs_enabled (client and server)
#
# @param validate_sshd_file
#   Default value for validate_sshd_file (server)
#
# @param use_augeas
#   Default value to use augeas (client and server)
#
# @param server_options_absent
#   List of options to remove for server config (augeas only)
#
# @param client_options_absent
#   List of options to remove for client config (augeas only)
#
# @param use_issue_net
#   Use issue_net header
#
class ssh (
  Stdlib::Absolutepath $sshd_dir,
  Stdlib::Absolutepath $sshd_binary,
  Boolean $validate_sshd_file,
  Hash $sshd_default_options,
  Hash $ssh_default_options,
  Stdlib::Absolutepath $sshd_config,
  Stdlib::Absolutepath $ssh_config,
  Stdlib::Filemode $user_ssh_directory_default_mode,
  Stdlib::Filemode $user_ssh_config_default_mode,
  Integer $host_priv_key_group,
  String $service_name,
  Boolean $collect_enabled,
  Optional[Stdlib::Absolutepath] $sshd_environments_file     = undef,
  Optional[String] $server_package_name                      = undef,
  Optional[String] $client_package_name                      = undef,
  Hash[String[1],Hash[String[1],NotUndef]] $server_instances = {},
  Hash    $server_options                                    = {},
  Hash    $server_match_block                                = {},
  Hash    $client_options                                    = {},
  Hash    $users_client_options                              = {},
  String  $version                                           = 'present',
  Boolean $storeconfigs_enabled                              = true,
  Boolean $use_augeas                                        = false,
  Array   $server_options_absent                             = [],
  Array   $client_options_absent                             = [],
  Boolean $use_issue_net                                     = false,
  Boolean $purge_unmanaged_sshkeys                           = true,

) {
  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_server_options = lookup("${module_name}::server_options", Optional[Hash], 'deep', {})
  $hiera_server_match_block = lookup("${module_name}::server_match_block", Optional[Hash], 'deep', {})
  $hiera_client_options = lookup("${module_name}::client_options", Optional[Hash], 'deep', {})
  $hiera_users_client_options = lookup("${module_name}::users_client_options", Optional[Hash], 'deep', {})

  $fin_server_options = deep_merge($hiera_server_options, $server_options)
  $fin_server_match_block = deep_merge($hiera_server_match_block, $server_match_block)
  $fin_client_options = deep_merge($hiera_client_options, $client_options)
  $fin_users_client_options = deep_merge($hiera_users_client_options, $users_client_options)

  class { 'ssh::server':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_server_options,
    validate_sshd_file   => $validate_sshd_file,
    use_augeas           => $use_augeas,
    options_absent       => $server_options_absent,
    use_issue_net        => $use_issue_net,
  }

  class { 'ssh::client':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_client_options,
    use_augeas           => $use_augeas,
    options_absent       => $client_options_absent,
  }

  $server_instances.each | String $instance_name, Hash $instance_settings | {
    ssh::server::instances { $instance_name:
      * => $instance_settings,
    }
  }

  # If host keys are being managed, optionally purge unmanaged ones as well.
  if ($storeconfigs_enabled and $purge_unmanaged_sshkeys) {
    resources { 'sshkey':
      purge => true,
    }
  }

  create_resources('ssh::client::config::user', $fin_users_client_options)
  create_resources('ssh::server::match_block', $fin_server_match_block)
}
