class ssh::client {
  include ssh::params
  include ssh::client::install
  include ssh::client::config
  include ssh::knownhosts
}
