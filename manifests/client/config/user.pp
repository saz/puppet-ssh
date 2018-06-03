#
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
# Contributor: Remi Ferrand <remi{dot}ferrand_at_cc(dot)in2p3.fr> (2015)
#
define ssh::client::config::user(
  Enum['present', 'absent']      $ensure              = present,
  Optional[Stdlib::Absolutepath] $target              = undef,
  Optional[Stdlib::Absolutepath] $user_home_dir       = undef,
  Boolean                        $manage_user_ssh_dir = true,
  Hash $options                                       = {}
)
{
  include ::ssh::params

  $_files_ensure = $ensure ? { 'present' => 'file', 'absent' => 'absent' }

  # If a specific target file was specified,
  # it must have higher priority than any
  # other parameter.
  if ($target != undef) {
    $_target = $target
  }
  else {
    if ($user_home_dir == undef) {
      $_user_home_dir = "/home/${name}"
    }
    else {
      $_user_home_dir = $user_home_dir
    }

    $user_ssh_dir = "${_user_home_dir}/.ssh"
    $_target      = "${user_ssh_dir}/config"

    if ($manage_user_ssh_dir == true) {
      file { $user_ssh_dir:
        ensure => directory,
        owner  => $name,
        mode   => $::ssh::params::user_ssh_directory_default_mode,
        before => File[$_target],
      }
    }
  }

  file { $_target:
    ensure  => $_files_ensure,
    owner   => $name,
    mode    => $::ssh::params::user_ssh_config_default_mode,
    content => template("${module_name}/ssh_config.erb"),
  }
}
