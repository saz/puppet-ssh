# @summary
#   Internal define to managed ssh server param
#
# @param key
#   Key of the value which should be set
#
# @param value
#   Value which should be set
#
# @param order
#   Orders your setting within the config file
#
define ssh::server::config::setting (
  String[1]                             $key,
  Variant[Boolean, Array, Hash, String] $value,
  Variant[String[1], Integer]           $order = '10'
) {
  include ssh::server

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
    target  => $ssh::server::sshd_config,
    content => "\n# added by Ssh::Server::Config::Setting[${name}]\n${key} ${real_value}\n",
    order   => $order,
  }
}
