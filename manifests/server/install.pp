class ssh::server::install {
  include ssh::params
  package { $ssh::params::server_package_name:
    ensure => present,
  }
}
