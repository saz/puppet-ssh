# @summary
#   Install ssh server package
#
# @api private
#
class ssh::server::install {
  include ssh::params
  if $ssh::params::server_package_name {
    ensure_packages(
      [$ssh::params::server_package_name],
      { 'ensure' => $ssh::server::ensure }
    )
  }
}
