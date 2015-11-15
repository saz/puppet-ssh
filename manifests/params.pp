class ssh::params {
  case $::osfamily {
    debian: {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-client'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'ssh'
      $sftp_server_path = '/usr/lib/openssh/sftp-server'
    }
    redhat: {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-clients'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/openssh/sftp-server'
    }
    freebsd: {
      $server_package_name = undef
      $client_package_name = undef
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
    }
    openbsd: {
      $server_package_name = undef
      $client_package_name = undef
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
    }
    archlinux: {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd.service'
      $sftp_server_path = '/usr/lib/ssh/sftp-server'
    }
    suse: {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      case $::operatingsystem {
        sles: {
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib64/ssh/sftp-server'
        }
        opensuse: {
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib/ssh/sftp-server'
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
    solaris: {
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'svc:/network/ssh:default'
      $sftp_server_path = 'internal-sftp'
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
    default: {
      case $::operatingsystem {
        gentoo: {
          $server_package_name = 'openssh'
          $client_package_name = 'openssh'
          $sshd_dir = '/etc/ssh'
          $sshd_config = '/etc/ssh/sshd_config'
          $ssh_config = '/etc/ssh/ssh_config'
          $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib/misc/sftp-server'
        }
        amazon: {
          $server_package_name = 'openssh-server'
          $client_package_name = 'openssh-clients'
          $sshd_dir = '/etc/ssh'
          $sshd_config = '/etc/ssh/sshd_config'
          $ssh_config = '/etc/ssh/ssh_config'
          $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
          $service_name = 'sshd'
          $sftp_server_path = '/usr/libexec/openssh/sftp-server'
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
    openbsd: {
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
    solaris: {
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

  $user_ssh_directory_default_mode = '0700'
  $user_ssh_config_default_mode    = '0600'
  $collect_enabled                 = true   # Collect sshkey resources
}
