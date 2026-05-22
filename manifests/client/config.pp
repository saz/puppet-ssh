# @summary
#   Manages ssh configuration
#
# @api private
#
class ssh::client::config {
  assert_private()

  $options = $ssh::client::merged_options
  $include_dir = $ssh::client::include_dir
  $use_augeas = $ssh::client::use_augeas

  if $use_augeas {
    $options.each |String $k, Hash $v| {
      ssh_config { $k:
        * => $v,
      }
    }
  } else {
    concat { $ssh::client::ssh_config:
      ensure => present,
      owner  => $ssh::client::config_user,
      group  => $ssh::client::config_group,
      mode   => '0644',
    }

    concat::fragment { 'ssh_config global config':
      target  => $ssh::client::ssh_config,
      content => template("${module_name}/ssh_config.erb"),
      order   => '00',
    }
  }

  if $ssh::client::include_dir {
    file { $ssh::client::include_dir:
      ensure  => directory,
      owner   => $ssh::client::config_user,
      group   => $ssh::client::config_group,
      mode    => $ssh::client::include_dir_mode,
      purge   => $ssh::client::include_dir_purge,
      recurse => $ssh::client::include_dir_purge,
    }

    $ssh::client::config_files.each |$file, $params| {
      ssh::client::config_file { $file:
        * => $params,
      }
    }
  }
}
