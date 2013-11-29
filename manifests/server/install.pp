class ssh::server::install {
  include ssh::params
  if $ssh::params::server_package_name == undef {
    package { $ssh::params::server_package_name:
      ensure => present,
    }
  }
}
