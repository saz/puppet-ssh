class ssh::hostkeys {
  $ipaddresses = ipaddresses()
  $host_aliases = flatten([ $::fqdn, $::hostname, $ipaddresses ])

  anchor { 'ssh::hostkeys::begin': } 
  anchor { 'ssh::hostkeys::end': } 

  if $::settings::storeconfigs {
    include ssh::hostkeys::storeconfigs
    Anchor['ssh::hostkeys::begin'] ->
    Class['ssh::hostkeys::storeconfigs'] ->
    Anchor['ssh::hostkeys::end']
  } else {
    include ssh::hostkeys::no_storeconfigs
    Anchor['ssh::hostkeys::begin'] ->
    Class['ssh::hostkeys::no_storeconfigs'] ->
    Anchor['ssh::hostkeys::end']
  }
}
