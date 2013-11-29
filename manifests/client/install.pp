class ssh::client::install {
  if $ssh::params::client_package_name == undef {
    package { $ssh::params::client_package_name:
      ensure => latest,
    }
  }
}
