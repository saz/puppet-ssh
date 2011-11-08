class ssh::client {
    include ssh::params, ssh::client::install, ssh::client::config, ssh::knownhosts
}
