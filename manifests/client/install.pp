class ssh::client::install {
  if $ssh::client_package_name {
    ensure_packages([
        $ssh::client_package_name,
      ], {
        'ensure' => $ssh::client::ensure,
    })
  }
}
