# @summary
#   Install ssh server package
#
# @api private
#
class ssh::server::install {
  include ssh
  if $ssh::server_package_name {
    ensure_packages ([
        $ssh::server_package_name,
      ], {
        'ensure' => $ssh::server::ensure,
    })
  }
}
