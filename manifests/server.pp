class ssh::server {
  include ssh::params
  include ssh::server::install
  include ssh::server::config
  include ssh::server::service
  include ssh::hostkeys
  include ssh::knownhosts
}
