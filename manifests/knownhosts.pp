# @summary
#   This class manged knownhosts if collect is enable
#
# @param collect_enabled
#   Enabled collect
#
# @param storeconfigs_group
#   Define the hostkeys group storage
#
class ssh::knownhosts(
  Boolean          $collect_enabled    = $ssh::params::collect_enabled,
  Optional[String] $storeconfigs_group = undef,
) inherits ssh::params {
  if ($collect_enabled) {
    if $storeconfigs_group {
      Sshkey <<| tag == "hostkey_${storeconfigs_group}" |>>
    } else {
      Sshkey <<| |>>
    }
  }
}
