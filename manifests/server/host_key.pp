# @summary
#   Manage a ssh host key
#
#   This module install a ssh host key in the server (basically, it is
#   a file resource but it also notifies to the ssh service)
#
#   Important! This define does not modify any option in sshd_config, so
#   you have to manually define the HostKey option in the server options
#   if you haven't done yet.
#
# @param ensure
#   Set to 'absent' to remove host_key files
#
# @param public_key_source
#   Sets the content of the source parameter for the public key file
#   Note public_key_source and public_key_content are mutually exclusive.
#
# @param public_key_content
#   Sets the content for the public key file.
#   Note public_key_source and public_key_content are mutually exclusive.
#
# @param private_key_source
#   Sets the content of the source parameter for the private key file
#   Note private_key_source and private_key_content are mutually exclusive.
#
# @param private_key_content
#   Sets the content for the private key file.
#   Note private_key_source and private_key_content are mutually exclusive.
#
# @param certificate_source
#   Sets the content of the source parameter for the host key certificate.
#   Note certificate_source and certificate_content are mutually exclusive.
#
# @param certificate_content
#   Sets the content for the host key certificate.
#   Note certificate_source and certificate_content are mutually exclusive.
#
define ssh::server::host_key (
  Enum[present, absent] $ensure              = 'present',
  Optional[String[1]]   $public_key_source   = undef,
  Optional[String[1]]   $public_key_content  = undef,
  Optional[String[1]]   $private_key_source  = undef,
  Optional[String[1]]   $private_key_content = undef,
  Optional[String[1]]   $certificate_source  = undef,
  Optional[String[1]]   $certificate_content = undef,
) {
  # Ensure the ssh::server class is included in the manifest
  include ssh::server

  if $ensure == 'present' {
    if ! $public_key_source and ! $public_key_content {
      fail('You must provide either public_key_source or public_key_content parameter')
    }

    if ! $private_key_source and ! $private_key_content {
      fail('You must provide either private_key_source or private_key_content parameter')
    }
  }

  $manage_pub_key_content = $public_key_source ? {
    undef   => $public_key_content,
    default => undef,
  }
  $manage_pub_key_source = $public_key_source ? {
    undef   => undef,
    default => $public_key_source,
  }

  $manage_priv_key_content = $private_key_source ? {
    undef   => $private_key_content,
    default => undef,
  }
  $manage_priv_key_source = $private_key_source ? {
    undef   => undef,
    default => $private_key_source,
  }

  $manage_cert_content = $certificate_source ? {
    undef   => $certificate_content,
    default => undef,
  }
  $manage_cert_source = $certificate_source ? {
    undef   => undef,
    default => $certificate_source,
  }

  if $ensure == 'present' {
    file { "${name}_pub":
      ensure  => $ensure,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      path    => "${ssh::server::sshd_dir}/${name}.pub",
      source  => $manage_pub_key_source,
      content => $manage_pub_key_content,
      notify  => Class['ssh::server::service'],
    }

    file { "${name}_priv":
      ensure    => $ensure,
      owner     => 0,
      group     => $ssh::server::host_priv_key_group,
      mode      => '0600',
      path      => "${ssh::server::sshd_dir}/${name}",
      source    => $manage_priv_key_source,
      content   => $manage_priv_key_content,
      show_diff => false,
      notify    => Class['ssh::server::service'],
    }
  } else {
    file { "${name}_pub":
      ensure => $ensure,
      owner  => 0,
      group  => 0,
      mode   => '0644',
      path   => "${ssh::server::sshd_dir}/${name}.pub",
      notify => Class['ssh::server::service'],
    }

    file { "${name}_priv":
      ensure    => $ensure,
      owner     => 0,
      group     => $ssh::server::host_priv_key_group,
      mode      => '0600',
      path      => "${ssh::server::sshd_dir}/${name}",
      show_diff => false,
      notify    => Class['ssh::server::service'],
    }
  }

  if !empty($certificate_source) or !empty($certificate_content) {
    if $ensure == 'present' {
      file { "${name}_cert":
        ensure  => $ensure,
        owner   => 0,
        group   => 0,
        mode    => '0644',
        path    => "${ssh::server::sshd_dir}/${name}-cert.pub",
        source  => $manage_cert_source,
        content => $manage_cert_content,
        notify  => Class['ssh::server::service'],
      }
    } else {
      file { "${name}_cert":
        ensure => $ensure,
        owner  => 0,
        group  => 0,
        mode   => '0644',
        path   => "${ssh::server::sshd_dir}/${name}-cert.pub",
        notify => Class['ssh::server::service'],
      }
    }
  }
}
