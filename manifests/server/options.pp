# @summary
#   This defined type manages ssh server options
#
# @param options
#   Options which should be set
#
# @param order
#   Orders your settings within the config file
#
define ssh::server::options (
  Hash    $options = {},
  Integer $order   = 50
) {
  concat::fragment { "options ${name}":
    target  => $ssh::server::sshd_config,
    content => template("${module_name}/options.erb"),
    order   => 100+$order,
  }
}
