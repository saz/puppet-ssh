class ssh::server::config {
  file { $ssh::params::sshd_config:
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template("${module_name}/sshd_config.erb"),
    require => Class['ssh::server::install'],
    notify  => Class['ssh::server::service'],
  }
  file { $ssh::params::sshd_keysdir:
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    require => Class['ssh::server::install'],
  }
}
