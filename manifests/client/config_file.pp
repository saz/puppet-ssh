# @summary Resource type for managing a config file in the include dir.
#
# @param mode
#   File mode for the config file.
#
# @param include
#   Absolute path to config file to include at the top of the config file.
#   This is intended for including files not managed by this module.
#
# @param options
#   Dynamic hash for openssh client option
#
define ssh::client::config_file (
  Stdlib::Absolutepath $path = "${ssh::client::include_dir}/${name}.conf",
  Stdlib::Filemode $mode = '0644',
  Optional[Stdlib::Absolutepath] $include = undef,
  Hash $options = {},
) {
  if !$ssh::client::include_dir {
    fail('ssh::client::config_file() define not supported if ssh::client::include_dir not set')
  }

  concat { $path:
    ensure => present,
    owner  => $ssh::client::config_user,
    group  => $ssh::client::config_group,
    mode   => $mode,
  }

  concat::fragment { "ssh_config_file ${title}":
    target  => $path,
    content => template("${module_name}/ssh_config.erb"),
    order   => '00',
  }
}
