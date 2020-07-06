class ssh::client::install {
  if $ssh::params::client_package_name {
    ensure_packages([$ssh::params::client_package_name], {'ensure' => $ssh::client::ensure})
  }
}
