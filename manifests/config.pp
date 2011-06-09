class ssh::config {
    file { $ssh::params::service_config:
        ensure  => present,
        owner   => "root",
        group   => "root",
        mode    => 0600,
        source  => "puppet:///modules/ssh/sshd_config",
        require => Class["ssh::install"],
        notify  => Class["ssh::service"],
    }
}
