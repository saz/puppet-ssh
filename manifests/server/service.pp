class ssh::server::service (
  $ensure = 'running',
  $enable = true
){
  include ::ssh::params
  include ::ssh::server

  service { $ssh::params::service_name:
    ensure     => $ssh::server::service::ensure,
    hasstatus  => true,
    hasrestart => true,
    enable     => $ssh::server::service::enable,
    require    => Class['ssh::server::config'],
  }
}
