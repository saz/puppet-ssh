# @summary
#   Add match_block to ssh server config
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
define ssh::server::match_block (
  Hash                 $options = {},
  String[1]            $type    = 'user',
  Integer              $order   = 50,
  Stdlib::Absolutepath $target  = $ssh::server::sshd_config,
) {
  if $ssh::server::use_augeas {
    fail('ssh::server::match_block() define not supported with use_augeas = true')
  } else {
    concat::fragment { "match_block ${name}":
      target  => $target,
      content => template("${module_name}/sshd_match_block.erb"),
      order   => 200+$order,
    }
  }
}
