# @summary
#   Managed ssh server configuration
#
# @api private
#
class ssh::server::config {
  assert_private()

  $options = $ssh::server::merged_options
  $include_dir = $ssh::server::include_dir

  case $ssh::server::validate_sshd_file {
    true: {
      $sshd_validate_cmd = '/usr/sbin/sshd -tf %'
    }
    default: {
      $sshd_validate_cmd = undef
    }
  }

  if $ssh::server::use_augeas {
    $options.each |String $k, Hash $v| {
      if $k.downcase == 'subsystem' {
        $_v = $v.match(/(^(\w+)\s+(.*)$)/)
        sshd_config_subsystem { $v[2]:
          command => $v[3],
        }
      } else {
        sshd_config { $k:
          * => $v,
        }
      }
    }
  } else {
    concat { $ssh::server::sshd_config:
      ensure       => present,
      owner        => 0,
      group        => 0,
      mode         => $ssh::server::sshd_config_mode,
      validate_cmd => $sshd_validate_cmd,
      notify       => Service[$ssh::server::service_name],
    }

    concat::fragment { 'global config':
      target  => $ssh::server::sshd_config,
      content => template("${module_name}/sshd_config.erb"),
      order   => '00',
    }
  }

  if $ssh::server::include_dir {
    file { $ssh::server::include_dir:
      ensure  => directory,
      owner   => 0,
      group   => 0,
      mode    => $ssh::server::include_dir_mode,
      purge   => $ssh::server::include_dir_purge,
      recurse => $ssh::server::include_dir_purge,
    }

    $ssh::server::config_files.each |$file, $params| {
      ssh::server::config_file { $file:
        * => $params,
      }
    }
  }

  if $ssh::server::use_issue_net {
    file { $ssh::server::issue_net:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => $ssh::server::sshd_config_mode,
      content => template("${module_name}/issue.net.erb"),
      notify  => Service[$ssh::server::service_name],
    }

    concat::fragment { 'banner file':
      target  => $ssh::server::sshd_config,
      content => "Banner ${ssh::server::issue_net}\n",
      order   => '01',
    }
  }
}
