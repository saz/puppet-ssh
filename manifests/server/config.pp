class ssh::server::config {

  concat { $ssh::params::sshd_config:
    ensure => present,
    owner  => '0',
    group  => '0',
    mode   => '0600',
    notify => Class['ssh::server::service'],
  }

  concat::fragment { 'global config':
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/sshd_config.erb"),
    order   => '00'
  }
}
