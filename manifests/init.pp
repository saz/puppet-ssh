class ssh {
    include ssh::params, ssh::install, ssh::config, ssh::service, ssh::hostkeys, ssh::knownhosts, ssh::client
}
