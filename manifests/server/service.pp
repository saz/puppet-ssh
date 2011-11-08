class ssh::service {
    service { $ssh::params::sshd_config:
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        enable     => true,
        require    => Class["ssh::server::config"],
    }
}
