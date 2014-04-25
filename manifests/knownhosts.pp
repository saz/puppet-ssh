class ssh::knownhosts {

  anchor { 'ssh::knownhosts::begin': } 
  anchor { 'ssh::knownhosts::end': } 

  if $::settings::storeconfigs {
    include ssh::knownhosts::storeconfigs
    Anchor['ssh::knownhosts::begin'] ->
    Class['ssh::knownhosts::storeconfigs'] ->
    Anchor['ssh::knownhosts::end']
  } else {
    include ssh::knownhosts::no_storeconfigs
    Anchor['ssh::knownhosts::begin'] ->
    Class['ssh::knownhosts::no_storeconfigs'] ->
    Anchor['ssh::knownhosts::end']
  }
}
