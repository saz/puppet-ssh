# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @options
#   Structure see main class
#
#   ssh::instances { 'namevar': }
define ssh::server::instances (
  String  $ensure                                        = present,
  Hash    $options                                       = {},
  String  $service_ensure                                = 'running',
  Boolean $service_enable                                = true,
  Boolean $validate_config_file                          = false,
  Stdlib::Absolutepath $sshd_instance_config_file        = "${ssh::sshd_dir}/sshd_config.${title}",
  Stdlib::Absolutepath $sshd_binary                      = $ssh::sshd_binary,
  Optional[Stdlib::Absolutepath] $sshd_environments_file = $ssh::sshd_environments_file,
) {
  include ssh

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
      active  => true,
      enable  => true,
    }
  } else {
    fail ("Operating System ${facts['os']['name']} not supported, because Systemd is not available")
  }
}
