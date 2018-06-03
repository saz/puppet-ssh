# Main file for puppet-ssh
class ssh (
  Hash    $server_options        = {},
  Hash    $server_match_block    = {},
  Hash    $client_options        = {},
  Hash    $users_client_options  = {},
  String  $version               = 'present',
  Boolean $storeconfigs_enabled  = true,
  Boolean $validate_sshd_file    = $::ssh::params::validate_sshd_file,
  Boolean $use_augeas            = false,
  Array   $server_options_absent = [],
  Array   $client_options_absent = [],
  Boolean $use_issue_net         = false,
) inherits ssh::params {

  # Merge hashes from multiple layer of hierarchy in hiera
  $hiera_server_options = lookup("${module_name}::server_options", Optional[Hash], 'hash', undef)
  $hiera_server_match_block = lookup("${module_name}::server_match_block", Optional[Hash], 'hash', undef)
  $hiera_client_options = lookup("${module_name}::client_options", Optional[Hash], 'hash', undef)
  $hiera_users_client_options = lookup("${module_name}::users_client_options", Optional[Hash], 'hash', undef)

  $fin_server_options = $hiera_server_options ? {
    undef   => $server_options,
    ''      => $server_options,
    default => $hiera_server_options,
  }

  $fin_server_match_block = $hiera_server_match_block ? {
    undef   => $server_match_block,
    ''      => $server_match_block,
    default => $hiera_server_match_block,
  }

  $fin_client_options = $hiera_client_options ? {
    undef   => $client_options,
    ''      => $client_options,
    default => $hiera_client_options,
  }

  $fin_users_client_options = $hiera_users_client_options ? {
    undef   => $users_client_options,
    ''      => $users_client_options,
    default => $hiera_users_client_options,
  }

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

  create_resources('::ssh::client::config::user', $fin_users_client_options)
  create_resources('::ssh::server::match_block', $fin_server_match_block)
}
