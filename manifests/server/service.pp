class ssh::server::service {
  include ssh::params
  include ssh::server

  service { $ssh::params::service_name:
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['ssh::server::config'],
  }
}
