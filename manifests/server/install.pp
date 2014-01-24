class ssh::server::install {
  include ssh::params
  if !defined(Package[$ssh::params::server_package_name]) {
    package { $ssh::params::server_package_name:
      ensure => present,
    }
  }
}
