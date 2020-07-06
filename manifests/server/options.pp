# @summary
#   Managed ssh server options
#
# @api private
#
define ssh::server::options (
  Hash $options  = {},
  Integer $order = 50
) {
  concat::fragment { "options ${name}":
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/options.erb"),
    order   => 100+$order,
  }
}
