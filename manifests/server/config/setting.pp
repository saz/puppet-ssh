define ssh::server::config::setting (
  $key,
  $value,
  $order = '10'
) {
  include ::ssh::params

  if is_bool($value) {
    $real_value = $value ? {
      true    => 'yes',
      false   => 'no',
      default => undef
    }
  } elsif is_array($value) {
    $real_value = join($value, ' ')
  } elsif is_hash($value) {
    fail('Hash values are not supported')
  } else {
    $real_value = $value
  }

  concat::fragment { "ssh_setting_${name}_${key}":
    target  => $ssh::params::sshd_config,
    content => "\n# added by Ssh::Server::Config::Setting[${name}]\n${key} ${real_value}\n",
    order   => $order,
  }

}
