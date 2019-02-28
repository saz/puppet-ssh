# Main file for puppet-ssh
class ssh (
  Hash    $server_options          = {},
  Hash    $server_match_block      = {},
  Hash    $client_options          = {},
  Hash    $users_client_options    = {},
  String  $version                 = 'present',
  Boolean $storeconfigs_enabled    = true,
  Boolean $validate_sshd_file      = $::ssh::params::validate_sshd_file,
  Boolean $use_augeas              = false,
  Array   $server_options_absent   = [],
  Array   $client_options_absent   = [],
  Boolean $use_issue_net           = false,
  Boolean $purge_unmanaged_sshkeys = true,
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_server_options = lookup("${module_name}::server_options", Optional[Hash], 'deep', {})
  $hiera_server_match_block = lookup("${module_name}::server_match_block", Optional[Hash], 'deep', {})
  $hiera_client_options = lookup("${module_name}::client_options", Optional[Hash], 'deep', {})
  $hiera_users_client_options = lookup("${module_name}::users_client_options", Optional[Hash], 'deep', {})

  $fin_server_options = deep_merge($hiera_server_options, $server_options)
  $fin_server_match_block = deep_merge($hiera_server_match_block, $server_match_block)
  $fin_client_options = deep_merge($hiera_client_options, $client_options)
  $fin_users_client_options = deep_merge($hiera_users_client_options, $users_client_options)

  class { '::ssh::server':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_server_options,
    validate_sshd_file   => $validate_sshd_file,
    use_augeas           => $use_augeas,
    options_absent       => $server_options_absent,
    use_issue_net        => $use_issue_net,
  }

  class { '::ssh::client':
    ensure               => $version,
    storeconfigs_enabled => $storeconfigs_enabled,
    options              => $fin_client_options,
    use_augeas           => $use_augeas,
    options_absent       => $client_options_absent,
  }

  # If host keys are being managed, optionally purge unmanaged ones as well.
  if ($storeconfigs_enabled and $purge_unmanaged_sshkeys) {
    resources { 'sshkey':
      purge => true,
    }
  }

  create_resources('::ssh::client::config::user', $fin_users_client_options)
  create_resources('::ssh::server::match_block', $fin_server_match_block)
}
