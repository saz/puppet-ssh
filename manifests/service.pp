class ssh::service {
    service { $ssh::params::service_name:
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        enable     => true,
        require    => Class["ssh::config"],
    }
}
