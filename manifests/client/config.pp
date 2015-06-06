class ssh::client::config
{
  $options = $::ssh::client::merged_options

  file { $ssh::params::ssh_config:
    ensure  => present,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => template("${module_name}/ssh_config.erb"),
    require => Class['ssh::client::install'],
  }

  # Workaround for http://projects.reductivelabs.com/issues/2014
  file { $ssh::params::ssh_known_hosts:
    ensure => present,
    mode   => '0644',
  }
}
