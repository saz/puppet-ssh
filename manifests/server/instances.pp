# @summary
#   Configure separate ssh server instances
#
# @param ensure
#   Specifies whether the instance should be added or removed
#
# @param options
#   Set options for the instance
#
# @param service_ensure
#   Whether this instance service should be running or stopped, defaults to true when ensure is set to present, otherwise false
#
# @param service_enable
#   Whether this instance service should be started at boot. Will be added automatically if ensure is running/removed if ensure is stopped
#
# @param validate_config_file
#   Validate config file before applying
#
# @param sshd_instance_config_file
#   Path of the instance sshd config
#
# @param sshd_binary
#   Path to sshd binary
#
# @param sshd_environments_file
#   Path to environments file, if any
#
define ssh::server::instances (
  Enum[present, absent]          $ensure                    = present,
  Hash                           $options                   = {},
  Stdlib::Ensure::Service        $service_ensure            = $ensure ? { 'present' => 'running', 'absent' => 'stopped' },
  Boolean                        $service_enable            = ($service_ensure == 'running'),
  Boolean                        $validate_config_file      = false,
  Stdlib::Absolutepath           $sshd_instance_config_file = "${ssh::server::sshd_dir}/sshd_config.${title}",
  Stdlib::Absolutepath           $sshd_binary               = $ssh::server::sshd_binary,
  Optional[Stdlib::Absolutepath] $sshd_environments_file    = $ssh::server::sshd_environments_file,
) {
  include ssh::server

  $sshd_instance_config       = assert_type(Hash, pick($options['sshd_config'], {}))
  $sshd_instance_matchblocks  = assert_type(Hash, pick($options['match_blocks'], {}))
  $sshd_service_options       = $options['sshd_service_options']
  #check if server is a linux
  if $facts['kernel'] == 'Linux' {
    case $validate_config_file {
      true: {
        $validate_cmd = '/usr/sbin/sshd -tf %'
      }
      default: {
        $validate_cmd = undef
      }
    }

    concat { $sshd_instance_config_file:
      ensure       => $ensure,
      owner        => 0,
      group        => 0,
      mode         => '0600',
      validate_cmd => $validate_cmd,
      notify       => Service["${title}.service"],
    }

    concat::fragment { "sshd instance ${title} config":
      target  => $sshd_instance_config_file,
      content => template("${module_name}/ssh_instance.erb"),
      order   => '00',
    }

    $sshd_instance_matchblocks.each |String $matchblock_name, Hash $matchblock_options| {
      ssh::server::match_block { $matchblock_name:
        *      => $matchblock_options,
        target => $sshd_instance_config_file,
      }
    }

    systemd::unit_file { "${title}.service":
      content => template("${module_name}/ssh_instance_service.erb"),
      active  => ($service_ensure == 'running'),
      enable  => $service_enable,
    }
  } else {
    fail ("Operating System ${facts['os']['name']} not supported, because Systemd is not available")
  }
}
