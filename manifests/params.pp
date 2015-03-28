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
    Archlinux: {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      $service_name = 'sshd.service'
      $sftp_server_path = '/usr/lib/ssh/sftp-server'
    }
    Suse: {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $sshd_dir = '/etc/ssh'
      $sshd_config = '/etc/ssh/sshd_config'
      $ssh_config = '/etc/ssh/ssh_config'
      $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
      case $::operatingsystem {
        Sles: {
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib64/ssh/sftp-server'
        }
        OpenSuSE: {
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib/ssh/sftp-server'
        }
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
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
        Amazon: {
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

  # OpenBSDs openssh doesn't link against PAM, therefore
  # it doesn't know about the UsePAM option
  case $::osfamily {
    openbsd: {
      $sshd_default_options = {
        'ChallengeResponseAuthentication' => 'no',
        'X11Forwarding'                   => 'yes',
        'PrintMotd'                       => 'no',
        'AcceptEnv'                       => 'LANG LC_*',
        'Subsystem'                       => "sftp ${sftp_server_path}",
      }
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

    }
  }

  $ssh_default_options = {
    'Host *'                 => {
      'SendEnv'              => 'LANG LC_*',
      'HashKnownHosts'       => 'yes',
    },
  }
}
