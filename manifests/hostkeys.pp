# @summary
#   This class manages hostkeys
#
# @param export_ipaddresses
#   Whether ip addresses should be added as aliases
#
# @param storeconfigs_group
#   Tag hostkeys with this group to allow segregation
#
# @param extra_aliases
#   Additional aliases to set for host keys
#
# @param exclude_interfaces
#   List of interfaces to exclude
#
# @param exclude_interfaces_re
#   List of regular expressions to exclude interfaces
#
# @param exclude_ipaddresses
#   List of ip addresses to exclude
#
# @param use_trusted_facts
#   Whether to use trusted or normal facts
#
# @param tags
#   Array of custom tags
#
class ssh::hostkeys (
  Boolean                    $export_ipaddresses    = true,
  Optional[String[1]]        $storeconfigs_group    = undef,
  Array                      $extra_aliases         = [],
  Array                      $exclude_interfaces    = [],
  Array                      $exclude_interfaces_re = [],
  Array                      $exclude_ipaddresses   = [],
  Boolean                    $use_trusted_facts     = false,
  Optional[Array[String[1]]] $tags                  = undef,
) {
  if $use_trusted_facts {
    $fqdn_real = $trusted['certname']
    $hostname_real = $trusted['hostname']
  } else {
    # stick to legacy facts for older versions of facter
    $fqdn_real = $facts['networking']['fqdn']
    $hostname_real = $facts['networking']['hostname']
  }

  if $export_ipaddresses == true {
    $ipaddresses = ssh::ipaddresses($exclude_interfaces, $exclude_interfaces_re)
    $ipaddresses_real = $ipaddresses - $exclude_ipaddresses
    $host_aliases = sort(unique(flatten([$fqdn_real, $hostname_real, $extra_aliases, $ipaddresses_real])))
  } else {
    $host_aliases = sort(unique(flatten([$fqdn_real, $hostname_real, $extra_aliases])))
  }

  $storeconfigs_groups = $storeconfigs_group ? {
    undef   => [],
    default => ['hostkey_all', "hostkey_${storeconfigs_group}"],
  }

  $_tags = $tags ? {
    undef   => $storeconfigs_groups,
    default => $storeconfigs_groups + $tags,
  }

  ['dsa', 'rsa', 'ecdsa', 'ed25519'].each |String $key_type| {
    # can be removed as soon as we drop support for puppet 4
    # see https://tickets.puppetlabs.com/browse/FACT-1377?jql=project%20%3D%20FACT%20AND%20fixVersion%20%3D%20%22FACT%203.12.0%22
    if $key_type == 'ecdsa' {
      $key_type_real = 'ecdsa-sha2-nistp256'
    } else {
      $key_type_real = $key_type
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
