class ssh::knownhosts(
  Boolean          $collect_enabled    = $ssh::params::collect_enabled,
  Optional[String] $storeconfigs_group = undef,
) inherits ssh::params {
  if ($collect_enabled) {
    resources { 'sshkey':
      purge => true,
    }

    if $storeconfigs_group {
    Sshkey <<| tag == "hostkey_${storeconfigs_group}" |>>
    } else {
      Sshkey <<| |>>
    }
  }
}
