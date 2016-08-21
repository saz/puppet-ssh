define ssh::server::match_block ($options, $type = 'user', $order = 50,) {
  concat::fragment { "match_block ${name}":
    target  => $ssh::params::sshd_config,
    content => template("${module_name}/sshd_match_block.erb"),
    order   => 200+$order,
  }
}
