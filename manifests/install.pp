class ssh::install {
    package { $ssh::params::package_name:
        ensure => present,
    }
}
