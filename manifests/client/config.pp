class ssh::client::config
{
  $options = $::ssh::client::merged_options
  $use_augeas = $::ssh::client::use_augeas

  if $use_augeas {
    create_resources('ssh_config', $options)
  } else {
    file { $ssh::params::ssh_config:
      ensure  => present,
      owner   => $ssh::params::cfg_file_owner,
      group   => $ssh::params::cfg_file_group,
      mode    => $ssh::params::cfg_file_mode,
      content => template("${module_name}/ssh_config.erb"),
      require => Class['ssh::client::install'],
    }
  }
}
