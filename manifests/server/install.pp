class ssh::server::install {
  include ::ssh::params
  if $ssh::params::server_package_name {
    ensure_packages([$ssh::params::server_package_name], {
      'ensure'            => $ssh::server::ensure,
      'provider'          => $ssh::params::package_provider,
      'install_options'   => $ssh::params::package_install_options,
      'uninstall_options' => $ssh::params::package_uninstall_options,
    })
  }
}
