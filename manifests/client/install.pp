class ssh::client::install {
  if $ssh::params::client_package_name {
    if !defined(Package[$ssh::params::client_package_name]) {
      package { $ssh::params::client_package_name:
        ensure => $ssh::client::ensure,
      }
    }
  }
}
