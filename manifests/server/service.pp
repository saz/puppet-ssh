# @summary
#   This class manages the ssh server service
#
# @api private
#
class ssh::server::service {
  assert_private()

  service { $ssh::server::service_name:
    ensure     => $ssh::server::service_ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $ssh::server::service_enable,
    require    => Class['ssh::server::config'],
  }
}
