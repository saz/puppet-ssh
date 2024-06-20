# @summary Resource type for managing a config file in the include dir.
#
# @param mode
#   File mode for the config file.
#
# @param include
#   Absolute path to config file to include at the top of the config file. This
#   is intended for including files not managed by this module (crypto policies).
#
# @param options
#   Dynamic hash for openssh server option
#
define ssh::server::config_file (
  Stdlib::Absolutepath $path = "${ssh::server::include_dir}/${name}.conf",
  Stdlib::Filemode $mode = $ssh::server::sshd_config_mode,
  Optional[Stdlib::Absolutepath] $include = undef,
  Hash $options = {},
) {
  if !$ssh::server::include_dir {
    fail('ssh::server::config_file() define not supported if ssh::server::include_dir not set')
  }

  case $ssh::server::validate_sshd_file {
    true: {
      $sshd_validate_cmd = '/usr/sbin/sshd -tf %'
    }
    default: {
      $sshd_validate_cmd = undef
    }
  }

  concat { $path:
    ensure       => present,
    owner        => 0,
    group        => 0,
    mode         => $mode,
    validate_cmd => $sshd_validate_cmd,
    notify       => Service[$ssh::server::service_name],
  }

  concat::fragment { "sshd_config_file ${title}":
    target  => $path,
    content => template("${module_name}/sshd_config.erb"),
    order   => '00',
  }
}
