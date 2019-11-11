# @summary
#   Params class
#
# @api private
#
class ssh::params {
  case $::osfamily {
    'Debian': {
      $server_package_name = 'openssh-server'
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = 'openssh-client'
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'ssh'
      $sftp_server_path = '/usr/lib/openssh/sftp-server'
      $cfg_file_owner = 0
      $cfg_file_group = 0
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 0
      $host_key_group = 0
      $host_key_mode = '0644'
      $host_priv_key_group = 0
      $host_priv_key_mode = '0600'
    }
    'RedHat': {
      $server_package_name = 'openssh-server'
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = 'openssh-clients'
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/openssh/sftp-server'
      $cfg_file_owner = 'root'
      $cfg_file_group = 'root'
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 'root'
      $host_key_group = 'root'
      $host_key_mode = '0644'
      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $host_priv_key_group = 'ssh_keys'
      } else {
        $host_priv_key_group = 0
      }
      $host_priv_key_mode = '0600'
    }
    'FreeBSD', 'DragonFly': {
      $server_package_name = undef
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = undef
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
      $cfg_file_owner = 0
      $cfg_file_group = 0
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 0
      $host_key_group = 0
      $host_key_mode = '0644'
      $host_priv_key_group = 0
      $host_priv_key_mode = '0600'
    }
    'OpenBSD': {
      $server_package_name = undef
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = undef
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
      $cfg_file_owner = 0
      $cfg_file_group = 0
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 0
      $host_key_group = 0
      $host_key_mode = '0644'
      $host_priv_key_group = 0
      $host_priv_key_mode = '0600'
    }
    'Darwin': {
      $server_package_name = undef
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = undef
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'com.openssh.sshd'
      $sftp_server_path = '/usr/libexec/sftp-server'
      $cfg_file_owner = 0
      $cfg_file_group = 0
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 0
      $host_key_group = 0
      $host_key_mode = '0644'
      $host_priv_key_group = 0
      $host_priv_key_mode = '0600'
    }
    'windows': {
      $server_package_name = 'openssh'
      $client_package_name = 'openssh'
      $package_install_options = ['-params', '""/SSHServerFeature""']
      $package_uninstall_options = ['-params','""/SSHServerFeature""']
      $package_provider = 'chocolatey'
      $home_dir_path = 'C:/Users'
      if $::architecture == 'x64' {
        $sshd_exe_dir = 'C:/Program Files/OpenSSH-Win64'
      }
      else {
        $sshd_exe_dir = 'C:/Program Files/OpenSSH-Win32'
      }
      $sshd_path = "${sshd_exe_dir}/sshd.exe"
      $ssh_cfg_dir = 'C:/ProgramData/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'sshd'
      $sftp_server_path = 'sftp-server.exe'
      $cfg_file_owner = 'Administrators'
      $cfg_file_group = 'Users'
      $cfg_file_mode = '0755'
      $cfg_priv_file_mode = '0750'
      $host_key_owner = 'Administrators'
      $host_key_group = 'NT SERVICE\SSHD'
      $host_key_mode = '0755'
      $host_priv_key_group = 'NT SERVICE\SSHD'
      $host_priv_key_mode = '0750'

    }
    'ArchLinux': {
      $server_package_name = 'openssh'
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = 'openssh'
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $service_name = 'sshd.service'
      $sftp_server_path = '/usr/lib/ssh/sftp-server'
      $cfg_file_owner = 0
      $cfg_file_group = 0
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 0
      $host_key_group = 0
      $host_key_mode = '0644'
      $host_priv_key_group = 0
      $host_priv_key_mode = '0600'
    }
    'Suse': {
      $server_package_name = 'openssh'
      $package_install_options = undef
      $package_uninstall_options = undef
      $client_package_name = 'openssh'
      $package_provider = undef
      $home_dir_path = '/home'
      $sshd_path = '/usr/sbin/sshd'
      $ssh_cfg_dir = '/etc/ssh'
      $sshd_config = "${ssh_cfg_dir}/sshd_config"
      $ssh_config = "${ssh_cfg_dir}/ssh_config"
      $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
      $cfg_file_owner = 0
      $cfg_file_group = 0
      $cfg_file_mode = '0644'
      $cfg_priv_file_mode = '0600'
      $host_key_owner = 0
      $host_key_group = 0
      $host_key_mode = '0644'
      $host_priv_key_group = 0
      $host_priv_key_mode = '0600'
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
          $package_install_options = undef
          $package_uninstall_options = undef
          $client_package_name = undef
          $package_provider = undef
          $home_dir_path = '/home'
          $sshd_path = '/usr/sbin/sshd'
          $ssh_cfg_dir = '/etc/ssh'
          $sshd_config = "${ssh_cfg_dir}/sshd_config"
          $ssh_config = "${ssh_cfg_dir}/ssh_config"
          $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
          $service_name = 'svc:/network/ssh:default'
          $sftp_server_path = 'internal-sftp'
          $cfg_file_owner = 0
          $cfg_file_group = 0
          $cfg_file_mode = '0644'
          $cfg_priv_file_mode = '0600'
          $host_key_owner = 0
          $host_key_group = 0
          $host_key_mode = '0644'
          $host_priv_key_group = 0
          $host_priv_key_mode = '0600'
        }
        default: {
          $ssh_cfg_dir = '/etc/ssh'
          $sshd_config = "${ssh_cfg_dir}/sshd_config"
          $ssh_config = "${ssh_cfg_dir}/ssh_config"
          $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
          $service_name = 'svc:/network/ssh:default'
          $sftp_server_path = 'internal-sftp'
          $package_install_options = undef
          $package_uninstall_options = undef
          $package_provider = undef
          $home_dir_path = '/home'
          $sshd_path = '/usr/sbin/sshd'
          $cfg_file_owner = 0
          $cfg_file_group = 0
          $cfg_file_mode = '0644'
          $cfg_priv_file_mode = '0600'
          $host_key_owner = 0
          $host_key_group = 0
          $host_key_mode = '0644'
          $host_priv_key_group = 0
          $host_priv_key_mode = '0600'
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
          $package_install_options = undef
          $package_uninstall_options = undef
          $client_package_name = 'openssh'
          $package_provider = undef
          $home_dir_path = '/home'
          $sshd_path = '/usr/sbin/sshd'
          $ssh_cfg_dir = '/etc/ssh'
          $sshd_config = "${ssh_cfg_dir}/sshd_config"
          $ssh_config = "${ssh_cfg_dir}/ssh_config"
          $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
          $service_name = 'sshd'
          $sftp_server_path = '/usr/lib/misc/sftp-server'
          $cfg_file_owner = 0
          $cfg_file_group = 0
          $cfg_file_mode = '0644'
          $cfg_priv_file_mode = '0600'
          $host_key_owner = 0
          $host_key_group = 0
          $host_key_mode = '0644'
          $host_priv_key_group = 0
          $host_priv_key_mode = '0600'
        }
        'Amazon': {
          $server_package_name = 'openssh-server'
          $package_install_options = undef
          $package_uninstall_options = undef
          $client_package_name = 'openssh-clients'
          $package_provider = undef
          $home_dir_path = '/home'
          $sshd_path = '/usr/sbin/sshd'
          $ssh_cfg_dir = '/etc/ssh'
          $sshd_config = "${ssh_cfg_dir}/sshd_config"
          $ssh_config = "${ssh_cfg_dir}/ssh_config"
          $ssh_known_hosts = "${ssh_cfg_dir}/ssh_known_hosts"
          $service_name = 'sshd'
          $sftp_server_path = '/usr/libexec/openssh/sftp-server'
          $cfg_file_owner = 0
          $cfg_file_group = 0
          $cfg_file_mode = '0644'
          $cfg_priv_file_mode = '0600'
          $host_key_owner = 0
          $host_key_group = 0
          $host_key_mode = '0644'
          $host_priv_key_group = 0
          $host_priv_key_mode = '0600'
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
  # - Windows doesn't know about UsePAM & override host key paths
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
          "${ssh_cfg_dir}/ssh_host_rsa_key",
          "${ssh_cfg_dir}/ssh_host_dsa_key",
        ],
      }
      $ssh_default_options = { }
    }
    'windows': {
      $sshd_default_options = {
        'AuthorizedKeysFile' => '.ssh/authorized_keys',
        'LogLevel'           => 'QUIET',
        'Subsystem'          => "sftp ${sftp_server_path}",
        'hostkeyagent'       => '\\\\.\pipe\openssh-ssh-agent',
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
