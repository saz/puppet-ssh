class ssh::server::config {
    file { $ssh::params::sshd_config:
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => 0600,
        source  => "puppet:///modules/${module_name}/sshd_config",
        require => Class["ssh::server::install"],
        notify  => Class["ssh::server::service"],
    }
}
