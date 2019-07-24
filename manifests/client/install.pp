class ssh::client::install {
  if $ssh::params::client_package_name {
    ensure_packages([$ssh::params::client_package_name], {
      'ensure'            => $ssh::client::ensure,
      'provider'          => $ssh::params::package_provider,
      'install_options'   => $ssh::params::package_install_options,
      'uninstall_options' => $ssh::params::package_uninstall_options,
    })
  }
}
