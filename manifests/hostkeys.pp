# @summary
#   This class manages hostkeys. It is intended to be called from `ssh::server`,
#   and directly accesses variables from there.
#
class ssh::hostkeys {

  if $ssh::server::use_trusted_facts {
    $fqdn_real = $trusted['certname']
    $hostname_real = $trusted['hostname']
  } else {
    # stick to normal facts
    $fqdn_real = $facts['networking']['fqdn']
    $hostname_real = $facts['networking']['hostname']
  }

  if $ssh::server::export_ipaddresses {
    $ipaddresses = ssh::ipaddresses($ssh::server::exclude_interfaces, $ssh::server::exclude_interfaces_re)
    $ipaddresses_real = $ipaddresses - $ssh::server::exclude_ipaddresses
    $host_aliases = sort(unique(flatten([$fqdn_real, $hostname_real, $ssh::server::extra_aliases, $ipaddresses_real])))
  } else {
    $host_aliases = sort(unique(flatten([$fqdn_real, $hostname_real, $ssh::server::extra_aliases])))
  }

  $storeconfigs_groups = $ssh::server::storeconfigs_group ? {
    undef   => [],
    default => ['hostkey_all', "hostkey_${ssh::server::storeconfigs_group}"],
  }

  $_tags = $ssh::server::tags ? {
    undef   => $storeconfigs_groups,
    default => $storeconfigs_groups + $ssh::server::tags,
  }

  ['dsa', 'rsa', 'ecdsa', 'ed25519'].each |String $key_type| {
    # adjustment for ecdsa using a diff file name from key type
    $key_type_real = $key_type ? {
      'ecdsa' => 'ecdsa-sha2-nistp256',
      default => $key_type,
    }

    if $key_type in $facts['ssh'] {
      @@sshkey { "${fqdn_real}_${key_type}":
        ensure       => present,
        host_aliases => $host_aliases,
        type         => $key_type_real,
        key          => $facts['ssh'][$key_type]['key'],
        tag          => $_tags,
      }
    } else {
      @@sshkey { "${fqdn_real}_${key_type}":
        ensure => absent,
        type   => $key_type_real,
      }
    }
  }
}
