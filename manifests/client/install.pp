class ssh::client::install (
  $ensure = present
) {
  if !defined(Package[$ssh::params::client_package_name]) {
    package { $ssh::params::client_package_name:
      ensure => $ensure,
    }
  }
}
