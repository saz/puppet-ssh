class ssh (
  $disable_user_known_hosts = true,
  $sshd_default_options = $ssh::params::sshd_default_options,
  $sshd_options         = {},
  $ssh_default_options  = $ssh::params::ssh_default_options,
  $ssh_options          = {}
) inherits ssh::params {
  include ssh::server
  include ssh::client
}
