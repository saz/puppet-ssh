class ssh::server::config {
  File[$ssh::params::sshd_config] ~> Service[$ssh::params::service_name]

  concat { $ssh::params::sshd_config:
    ensure => present,
    owner  => 0,
    group  => 0,
    mode   => '0600',
  }

  concat::fragment { 'global config':
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/sshd_config.erb"),
    order   => '00'
  }
  file { $ssh::params::sshd_keysdir:
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    require => Class['ssh::server::install'],
  }
}
