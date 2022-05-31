# @summary
#   Add match_block to ssh client config (concat needed)
#
# @param options
#   Options which should be set
#
# @param type
#   Type of match_block, e.g. user, group, host, ...
#
# @param order
#   Orders your settings within the config file
#
# @param target
#   Sets the target file of the concat fragment
#
define ssh::client::match_block (
  Hash                 $options = {},
  Ssh::ClientMatch     $type    = 'user',
  Integer              $order   = 50,
  Stdlib::Absolutepath $target  = $ssh::client::ssh_config,
) {
  if $ssh::client::use_augeas {
    fail('ssh::client::match_block() define not supported with use_augeas = true')
  } else {
    concat::fragment { "match_block ${name}":
      target  => $target,
      # same template may be used for ssh_config & sshd_config
      content => template("${module_name}/sshd_match_block.erb"),
      order   => 200+$order,
    }
  }
}
