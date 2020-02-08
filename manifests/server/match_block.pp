# @summary
#   Add match_block to ssh server config (concat needed)
#
# @api private
#
define ssh::server::match_block (
  Hash $options  = {},
  String $type   = 'user',
  Integer $order = 50,
) {
  if $ssh::server::use_augeas {
    fail('ssh::server::match_block() define not supported with use_augeas = true')
  } else {
    concat::fragment { "match_block ${name}":
      target  => $ssh::params::sshd_config,
      content => template("${module_name}/sshd_match_block.erb"),
      order   => 200+$order,
    }
  }
}
