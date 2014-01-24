class ssh::client::install {
  if !defined(Package[$ssh::params::client_package_name]) {
    package { $ssh::params::client_package_name:
      ensure => present,
    }
  }
}
