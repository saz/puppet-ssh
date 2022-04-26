#
# Copyright (c) IN2P3 Computing Centre, IN2P3, CNRS
# Contributor: Remi Ferrand <remi{dot}ferrand_at_cc(dot)in2p3.fr> (2015)
# Contributor: Tim Meusel <tim@bastelfreak.de> (2017)
#
# @summary
#   This defined type manages a users ssh config
#
# @param ensure
#   Specifies whether the config file should be present or absent
#
# @param target
#   Sets the config file location, defaults to `~/.ssh/config` if $target and $user_home_dir are not set
#
# @param user_home_dir
#   Sets the location of users home dir, defaults to `/home/$user`
#
# @param manage_user_ssh_dir
#   Whether the users ssh dir should be managed or not
#
# @param options
#   Options which should be set
#
# @param user
#   The name of the user the config should be managed for
#
# @param ssh_directory_default_mode
#   Default mode for the users ssh dir
#
# @param ssh_config_default_mode
#   Default mode for the ssh config file
#
define ssh::client::config::user (
  Enum['present', 'absent']      $ensure                     = present,
  Optional[Stdlib::Absolutepath] $target                     = undef,
  Optional[Stdlib::Absolutepath] $user_home_dir              = undef,
  Boolean                        $manage_user_ssh_dir        = true,
  Hash                           $options                    = {},
  String[1]                      $user                       = $name,
  String[1]                      $ssh_directory_default_mode = '0700',
  String[1]                      $ssh_config_default_mode    = '0600',
) {
  include ssh::client

  # If a specific target file was specified,
  # it must have higher priority than any
  # other parameter.
  if ($target != undef) {
    $_target = $target
  } else {
    if ($user_home_dir == undef) {
      $_user_home_dir = "/home/${user}"
    } else {
      $_user_home_dir = $user_home_dir
    }

    $user_ssh_dir = "${_user_home_dir}/.ssh"
    $_target      = "${user_ssh_dir}/config"

    if ($manage_user_ssh_dir == true) {
      unless defined(File[$user_ssh_dir]) {
        file { $user_ssh_dir:
          ensure => directory,
          owner  => $user,
          mode   => $ssh_directory_default_mode,
          before => Concat_file[$_target],
        }
      }
    }
  }

  unless defined(Concat_file[$_target]) {
    concat_file { $_target:
      ensure => $ensure,
      owner  => $user,
      mode   => $ssh_config_default_mode,
      tag    => $name,
    }
  }
  concat_fragment { $name:
    tag     => $name,
    content => template("${module_name}/ssh_config.erb"),
    target  => $_target,
  }
}
