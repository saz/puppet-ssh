# @summary
#   This class managed ssh server service
#
# @param ensure
#   Ensurable service param
#
# @param enable
#   Define if service is enable
#
class ssh::server::service (
  String  $ensure = 'running',
  Boolean $enable = true
) {
  include ssh
  include ssh::server

  service { $ssh::service_name:
    ensure     => $ssh::server::service::ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $ssh::server::service::enable,
    require    => Class['ssh::server::config'],
  }
}
