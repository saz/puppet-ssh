class ssh::client::config {
    file { $ssh::params::ssh_config:
        ensure  => present,
        owner   => root,
        group   => root,
        source  => "puppet:///modules/${module_name}/ssh_config",
        require => Class['ssh::client::install'],
    }
}
