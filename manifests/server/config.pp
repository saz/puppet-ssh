class ssh::server::config {
  concat { $ssh::params::sshd_config:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  }

  concat::fragment { 'global config':
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/sshd_config.erb"),
    order   => '00'
  }
}
