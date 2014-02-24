class ssh (
  $server_options = {},
  $client_options = {}
) inherits ssh::params {
  class { 'ssh::server':
    options => $server_options,
  }

  class { 'ssh::client':
    options => $client_options,
  }
}
