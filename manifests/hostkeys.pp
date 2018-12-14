# Class ssh::hostkeys
class ssh::hostkeys(
  Boolean          $export_ipaddresses  = true,
  Optional[String] $storeconfigs_group  = undef,
  Array            $extra_aliases       = [],
  Array            $exclude_interfaces  = [],
  Array            $exclude_ipaddresses = [],
) {

  if $export_ipaddresses == true {
    $ipaddresses_real = delete(ipaddresses($exclude_interfaces), $exclude_ipaddresses)
    $host_aliases = unique(flatten([ $::fqdn, $::hostname, $extra_aliases, $ipaddresses_real ]))
  } else {
    $host_aliases = unique(flatten([ $::fqdn, $::hostname, $extra_aliases]))
  }

  if $storeconfigs_group {
    tag 'hostkey_all', "hostkey_${storeconfigs_group}"
  }

  ['dsa', 'rsa', 'ecdsa', 'ed25519'].each |String $key_type| {
    if $key_type == 'ecdsa' {
      $key_type_real = 'ecdsa-sha2-nistp256'
    } else {
      $key_type_real = $key_type
    }

    if $key_type in $facts['ssh'] {
      @@sshkey { "${::fqdn}_${key_type}":
        ensure       => present,
        host_aliases => $host_aliases,
        type         => $key_type_real,
        key          => $facts['ssh'][$key_type]['key'],
      }
    } else {
      @@sshkey { "${::fqdn}_${key_type}":
        ensure => absent,
        type   => $key_type_real,
      }
    }
  }
}
