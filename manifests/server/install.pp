class ssh::server::install {
    package { $ssh::params::server_package_name:
        ensure => present,
    }
}
