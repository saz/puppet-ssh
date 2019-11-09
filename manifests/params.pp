# @summary
#   Params class
#
# @api private
#
class ssh::params {
  case $::osfamily {
    'Debian': {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-client'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'ssh'
      $sftp_server_path = '/usr/lib/openssh/sftp-server'
      $host_priv_key_group = 0
    }
    'RedHat': {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-clients'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/openssh/sftp-server'
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $host_priv_key_group = 'ssh_keys'
      } else {
        $host_priv_key_group = 0
      }
    }
    'FreeBSD', 'DragonFly': {
      $server_package_name = undef
      $client_package_name = undef
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
      $host_priv_key_group = 0
    }
    'OpenBSD': {
      $server_package_name = undef
      $client_package_name = undef
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
      $host_priv_key_group = 0
    }
    'Darwin': {
      $server_package_name = undef
      $client_package_name = undef
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'com.openssh.sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
      $host_priv_key_group = 0
    }
    'ArchLinux': {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd.service'
      $sftp_server_path = '/usr/lib/ssh/sftp-server'
      $host_priv_key_group = 0
    }
    'Suse': {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $host_priv_key_group = 0
      case $::operatingsystem {
        'SLES': {
          $service_name = 'sshd'
          # $::operatingsystemmajrelease isn't available on e.g. SLES 10
          case $::operatingsystemrelease {
            /^10\./, /^11\./: {
              if ($::architecture == 'x86_64') {
                $sftp_server_path = '/usr/lib64/ssh/sftp-server'
              } else {
                $sftp_server_path = '/usr/lib/ssh/sftp-server'
              }
            }
            default: {
              $sftp_server_path = '/usr/lib/ssh/sftp-server'
            }
          }
        }
        'OpenSuse': {
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib/ssh/sftp-server'
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
    'Solaris': {
      case $::operatingsystem {
        'SmartOS': {
          $server_package_name = undef
          $client_package_name = undef
          $sshd_dir = '/etc/ssh'
          $sshd_config = '/etc/ssh/sshd_config'
          $ssh_config = '/etc/ssh/ssh_config'
          $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
          $service_name = 'svc:/network/ssh:default'
          $sftp_server_path = 'internal-sftp'
          $host_priv_key_group = 0
        }
        default: {
          $sshd_dir = '/etc/ssh'
          $sshd_config = '/etc/ssh/sshd_config'
          $ssh_config = '/etc/ssh/ssh_config'
          $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
          $service_name = 'svc:/network/ssh:default'
          $sftp_server_path = 'internal-sftp'
          $host_priv_key_group = 0
          case versioncmp($::kernelrelease, '5.10') {
            1: {
              # Solaris 11 and later
              $server_package_name = '/service/network/ssh'
              $client_package_name = '/network/ssh'
            }
            0: {
              # Solaris 10
              $server_package_name = 'SUNWsshdu'
              $client_package_name = 'SUNWsshu'
            }
            default: {
              # Solaris 9 and earlier not supported
              fail("Unsupported platform: ${::osfamily}/${::kernelrelease}")
            }
          }
        }
      }
    }
    default: {
      case $::operatingsystem {
        'Gentoo': {
          $server_package_name = 'openssh'
          $client_package_name = 'openssh'
          $sshd_dir = '/etc/ssh'
          $sshd_config = '/etc/ssh/sshd_config'
          $ssh_config = '/etc/ssh/ssh_config'
          $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib/misc/sftp-server'
          $host_priv_key_group = 0
        }
        'Amazon': {
          $server_package_name = 'openssh-server'
          $client_package_name = 'openssh-clients'
          $sshd_dir = '/etc/ssh'
          $sshd_config = '/etc/ssh/sshd_config'
          $ssh_config = '/etc/ssh/ssh_config'
          $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
          $service_name = 'sshd'
          $sftp_server_path = '/usr/libexec/openssh/sftp-server'
          $host_priv_key_group = 0
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }

  # ssh & sshd default options:
  # - OpenBSD doesn't know about UsePAM
  # - Sun_SSH doesn't know about UsePAM & AcceptEnv; SendEnv & HashKnownHosts
  case $::osfamily {
    'OpenBSD': {
      $sshd_default_options = {
        'ChallengeResponseAuthentication' => 'no',
        'X11Forwarding'                   => 'yes',
        'PrintMotd'                       => 'no',
        'AcceptEnv'                       => 'LANG LC_*',
        'Subsystem'                       => "sftp ${sftp_server_path}",
      }
      $ssh_default_options = {
        'Host *'                 => {
          'SendEnv'              => 'LANG LC_*',
          'HashKnownHosts'       => 'yes',
        },
      }
    }
    'Solaris': {
      $sshd_default_options = {
        'ChallengeResponseAuthentication' => 'no',
        'X11Forwarding'                   => 'yes',
        'PrintMotd'                       => 'no',
        'Subsystem'                       => "sftp ${sftp_server_path}",
        'HostKey'                         => [
          "${sshd_dir}/ssh_host_rsa_key",
          "${sshd_dir}/ssh_host_dsa_key",
        ],
      }
      $ssh_default_options = { }
    }
    default: {
      $sshd_default_options = {
        'ChallengeResponseAuthentication' => 'no',
        'X11Forwarding'                   => 'yes',
        'PrintMotd'                       => 'no',
        'AcceptEnv'                       => 'LANG LC_*',
        'Subsystem'                       => "sftp ${sftp_server_path}",
        'UsePAM'                          => 'yes',
      }
      $ssh_default_options = {
        'Host *'                 => {
          'SendEnv'              => 'LANG LC_*',
          'HashKnownHosts'       => 'yes',
        },
      }
    }
  }

  $validate_sshd_file              = false
  $user_ssh_directory_default_mode = '0700'
  $user_ssh_config_default_mode    = '0600'
  $collect_enabled                 = true   # Collect sshkey resources
  $issue_net                       = '/etc/issue.net'
}
