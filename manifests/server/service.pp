class ssh::server::service (
  $ensure         = 'running',
  $enable         = true,
  $manage_service = true,
){
  include ssh::params
  include ssh::server

  if $manage_service {
    service { $ssh::params::service_name:
      ensure     => $ssh::server::service::ensure,
      hasstatus  => true,
      hasrestart => true,
      enable     => $ssh::server::service::enable,
      require    => Class['ssh::server::config'],
      subscribe  => Class['ssh::server::config'],
    }
  }
}
