class ssh::server::install {
  include ssh::params
  if $ssh::params::server_package_name {
    if !defined(Package[$ssh::params::server_package_name]) {
      package { $ssh::params::server_package_name:
        ensure   => $ssh::server::ensure,
      }
    }
  }
}
