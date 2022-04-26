# @summary
#   Install ssh client package
#
# @api private
#
class ssh::client::install {
  assert_private()

  if $ssh::client::client_package_name {
    ensure_packages([
        $ssh::client::client_package_name,
      ], {
        'ensure' => $ssh::client::ensure,
    })
  }
}
