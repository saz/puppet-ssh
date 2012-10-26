class ssh::server::config {
  file { $ssh::params::sshd_config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    replace => false,
    source  => "puppet:///modules/${module_name}/sshd_config",
    require => Class['ssh::server::install'],
    notify  => Class['ssh::server::service'],
  }
}
