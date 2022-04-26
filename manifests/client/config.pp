# @summary
#   Manages ssh configuration
#
# @api private
#
class ssh::client::config {
  assert_private()

  $options = $ssh::client::merged_options
  $use_augeas = $ssh::client::use_augeas

  if $use_augeas {
    create_resources('ssh_config', $options)
  } else {
    file { $ssh::client::ssh_config:
      ensure  => file,
      owner   => '0',
      group   => '0',
      mode    => '0644',
      content => template("${module_name}/ssh_config.erb"),
      require => Class['ssh::client::install'],
    }
  }
}
