class ssh::server::config {
  $warn_message = $ssh::server::warn_message
  file { $ssh::params::sshd_config:
    ensure  => present,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template("${module_name}/sshd_config.erb"),
    require => Class['ssh::server::install'],
    notify  => Class['ssh::server::service'],
  }
}
