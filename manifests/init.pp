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
# @param server_options
#   Add dynamic options for ssh server config
#
# @param server_match_block
#   Add match block for ssh server config
#
# @param client_options
#   Add dynamic options for ssh client config
#
# @param client_match_block
#   Add match block for ssh client config
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
# @param purge_unmanaged_sshkeys
#   Purge unmanaged sshkeys
#
# @param server_instances
#   Configure SSH instances
#
class ssh (
  Optional[Hash]                           $server_options          = undef,
  Hash                                     $server_match_block      = {},
  Optional[Hash]                           $client_options          = undef,
  Hash                                     $client_match_block      = {},
  Hash                                     $users_client_options    = {},
  String                                   $version                 = 'present',
  Boolean                                  $storeconfigs_enabled    = true,
  Boolean                                  $validate_sshd_file      = false,
  Boolean                                  $use_augeas              = false,
  Array                                    $server_options_absent   = [],
  Array                                    $client_options_absent   = [],
  Boolean                                  $use_issue_net           = false,
  Boolean                                  $purge_unmanaged_sshkeys = true,
  Hash[String[1],Hash[String[1],NotUndef]] $server_instances        = {},
) {
  class { 'ssh::server':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $server_options,
    validate_sshd_file   => $validate_sshd_file,
    use_augeas           => $use_augeas,
    options_absent       => $server_options_absent,
    use_issue_net        => $use_issue_net,
  }

  class { 'ssh::client':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $client_options,
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

  $users_client_options.each |String $k, Hash $v| {
    ssh::client::config::user { $k:
      * => $v,
    }
  }

  $server_match_block.each |String $k, Hash $v| {
    ssh::server::match_block { $k:
      * => $v,
    }
  }

  $client_match_block.each |String $k, Hash $v| {
    ssh::client::match_block { $k:
      * => $v,
    }
  }
}
