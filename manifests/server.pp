class ssh::server {
    include ssh::params, ssh::server::install, ssh::server::config, ssh::server::service, ssh::hostkeys, ssh::knownhosts
}
