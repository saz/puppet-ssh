class ssh::server::config {

  concat { $ssh::params::sshd_config:
    ensure => present,
    owner  => '0',
    group  => '0',
    mode   => '0600',
    notify => Service[$ssh::params::service_name]
  }

  concat::fragment { 'global config':
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/sshd_config.erb"),
    order   => '00'
  }
}
