define ssh::server::match_block ($type = 'user', $order = 50, $options,) {
  concat::fragment { "match_block ${name}":
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/sshd_match_block.erb"),
    order   => $order,
  }
}
