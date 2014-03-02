class ssh::server::install (
    $ensure = present
) {
  include ssh::params
  if !defined(Package[$ssh::params::server_package_name]) {
    package { $ssh::params::server_package_name:
      ensure => $ensure,
    }
  }
}
