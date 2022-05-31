# @summary
#   Managed ssh server configuration
#
# @api private
#
class ssh::server::config {
  assert_private()

  $options = $ssh::server::merged_options

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
      sshd_config { $k:
        * => $v,
      }
    }
  } else {
    concat { $ssh::server::sshd_config:
      ensure       => present,
      owner        => 0,
      group        => 0,
      mode         => '0600',
      validate_cmd => $sshd_validate_cmd,
      notify       => Service[$ssh::server::service_name],
    }

    concat::fragment { 'global config':
      target  => $ssh::server::sshd_config,
      content => template("${module_name}/sshd_config.erb"),
      order   => '00',
    }
  }

  if $ssh::server::use_issue_net {
    file { $ssh::server::issue_net:
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
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
