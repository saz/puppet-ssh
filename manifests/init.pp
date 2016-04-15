# Main file for puppet-ssh
class ssh (
  $server_options       = {},
  $server_match_block   = {},
  $client_options       = {},
  $users_client_options = {},
  $version              = 'present',
  $storeconfigs_enabled = true,
) inherits ssh::params {

  validate_hash($server_options)
  validate_hash($server_match_block)
  validate_hash($client_options)
  validate_hash($users_client_options)
  validate_bool($storeconfigs_enabled)

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_server_options = hiera_hash("${module_name}::server_options", {})
  $hiera_server_match_block = hiera_hash("${module_name}::server_match_block", {})
  $hiera_client_options = hiera_hash("${module_name}::client_options", {})
  $hiera_users_client_options = hiera_hash("${module_name}::users_client_options", {})

  if empty($hiera_server_options) {
    $fin_server_options = $server_options
  } else {
    $fin_server_options = $hiera_server_options
  }

  if empty($hiera_server_match_block) {
    $fin_server_match_block = $server_match_block
  } else {
    $fin_server_match_block = $hiera_server_match_block
  }

  if empty($hiera_client_options) {
    $fin_client_options = $client_options
  } else {
    $fin_client_options = $hiera_client_options
  }

  if empty($hiera_users_client_options) {
    $fin_users_client_options = $users_client_options
  } else {
    $fin_users_client_options = $hiera_users_client_options
  }

  class { 'ssh::server':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_server_options,
  }

  class { 'ssh::client':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_client_options,
  }

  create_resources('::ssh::client::config::user', $fin_users_client_options)
  create_resources('::ssh::server::match_block', $fin_server_match_block)
}
