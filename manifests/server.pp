class ssh::server(
  $default_options = $ssh::params::sshd_default_options,
  $options         = {}
) inherits ssh::params {

  include ssh::server::install
  include ssh::server::config
  include ssh::server::service
  include ssh::hostkeys
  include ssh::knownhosts

  anchor { 'ssh::server::start': }
  anchor { 'ssh::server::end': }

  Anchor['ssh::server::start'] ->
  Class['ssh::server::install'] ->
  Class['ssh::server::config'] ~>
  Class['ssh::server::service'] ->
  Class['ssh::hostkeys'] ->
  Class['ssh::knownhosts'] ->
  Anchor['ssh::server::end']
}
