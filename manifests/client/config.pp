class ssh::client::config {
  file { $ssh::params::ssh_config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/${module_name}/ssh_config",
    require => Class['ssh::client::install'],
  }

  # Workaround for http://projects.reductivelabs.com/issues/2014
  file { $ssh::params::ssh_known_hosts:
    mode => '0644',
  }
}
