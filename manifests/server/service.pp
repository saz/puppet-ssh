# @summary
#   This class managed ssh server service
#
# @api private
#
# @param ensure
#   Ensurable service param
#
# @param enable
#   Define if service is enable
#
class ssh::server::service (
  Stdlib::Ensure::Service $ensure = 'running',
  Boolean                 $enable = true,
) {
  assert_private()

  service { $ssh::server::service_name:
    ensure     => $ssh::server::service::ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $ssh::server::service::enable,
    require    => Class['ssh::server::config'],
  }
}
