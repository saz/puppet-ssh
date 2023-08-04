# @summary
#   Install ssh server package
#
# @api private
#
class ssh::server::install {
  assert_private()

  if $ssh::server::server_package_name {
    package { $ssh::server::server_package_name: ensure => $ssh::server::ensure }
  }
}
