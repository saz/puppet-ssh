class ssh::client::install {
  package { $ssh::params::client_package_name:
    ensure => latest,
  }
}
